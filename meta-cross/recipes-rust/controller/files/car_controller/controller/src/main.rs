use vehicle_control::*;

use std::net::UdpSocket;
use std::sync::mpsc;
use std::thread;
use std::time::{Duration, Instant};

#[derive(PartialEq, Debug)]
enum DriveMode {
    Manual,
    Autonomous,
}

fn spawn_gamepad_thread(
    dev_fn: &str,
) -> Result<(mpsc::Receiver<GamepadInput>, thread::JoinHandle<()>), Box<dyn std::error::Error>> {
    let mut gamepad = Gamepad::new(dev_fn).map_err(|e| format!("Failed to open gamepad: {}", e))?;

    let (input_tx, input_rx) = mpsc::channel::<GamepadInput>();
    let handle = thread::spawn(move || loop {
        gamepad.update();
        if input_tx.send(*gamepad.get_input()).is_err() {
            break;
        }
        thread::sleep(Duration::from_millis(1));
    });

    Ok((input_rx, handle))
}

fn recv_latest_input(
    input_rx: &mpsc::Receiver<GamepadInput>,
    timeout: Duration,
) -> Option<GamepadInput> {
    let mut latest = input_rx.recv_timeout(timeout).ok()?;
    while let Ok(newer) = input_rx.try_recv() {
        latest = newer;
    }
    Some(latest)
}

/*
    MANUAL MODE
    also known as MANUEL MODE
*/
fn run_manual_mode(
    input_rx: &mpsc::Receiver<GamepadInput>,
    controller: &MotorController,
) -> Result<Option<DriveMode>, Box<dyn std::error::Error>> {
    println!("MANUEL MODE - Press B to exit");
    // =================================================================================
    //                              INIT HELPER VARIABLES
    // previous values
    let mut prev_motor_speed: u32 = 0;
    let mut prev_servo_angle: u32 = 90;
    let mut prev_d_pad = false;
    let mut prev_cruise_button = false;
    let mut prev_direction = NEUTRAL;

    // cruise control variables
    let mut cruise_control_enabled = false;
    let mut cruise_direction: u8 = NEUTRAL;
    let mut cruise_speed: u32 = 0;

    let mut next_mode: Option<DriveMode> = None;

    // =================================================================================

    loop {
        // =================================================================================
        //                          GAMEPAD INPUT THREAD

        let Some(input) = recv_latest_input(input_rx, Duration::from_millis(25)) else {
            eprintln!("Gamepad input thread disconnected");
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break;
        };

        // =================================================================================
        //                          EXITING MANUEL MODE

        if input.button_b {
            println!("Exiting MANUEL mode");
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break;
        }

        // =================================================================================
        //                          ENTERING AUTONOMOUS MODE

        if input.button_y {
            println!("Entering AUTONOMOUS mode");
            next_mode = Some(DriveMode::Autonomous);
            break;
        }

        // =================================================================================
        //                          GAMEPAD INPUT VARIABLES

        let steering = input.analog_stick_right.x;
        let throttle = input.analog_stick_left.y;
        let max_speed = input.button_r2;
        let brake = input.button_l2;
        let d_pad: bool = input.d_pad.y as i8 != 0;

        // =================================================================================
        //                          DEFINING DIRECTION

        let direction = if brake {
            BRAKE
        } else if throttle > 0.0 {
            FORWARD
        } else if throttle < 0.0 {
            REVERSE
        } else {
            NEUTRAL
        };

        // =================================================================================
        //                          CHANGING CRUISE CONTROL SPEED VALUE

        if cruise_control_enabled {
            if d_pad && !prev_d_pad {
                if input.d_pad.y < 0.0 {
                    cruise_speed = cruise_speed.saturating_sub(STEP_CRUISE).max(MIN_CRUISE);
                } else if input.d_pad.y > 0.0 {
                    cruise_speed = cruise_speed.saturating_add(STEP_CRUISE).min(MAX_CRUISE);
                }
            }
        }
        prev_d_pad = d_pad;

        // =================================================================================
        //                          ACTIVATING CRUISE CONTROL

        if input.button_l3 && !prev_cruise_button {
            if cruise_control_enabled {
                cruise_control_enabled = false;
            } else if direction == FORWARD {
                cruise_control_enabled = true;
                cruise_speed = prev_motor_speed;
                cruise_direction = direction;
            }
        }
        if direction == BRAKE || direction == REVERSE {
            cruise_control_enabled = false;
        }
        prev_cruise_button = input.button_l3;

        // =================================================================================
        //                      DEFINING SPEED AND ANGLES

        let joystick_motor_speed = if max_speed {
            (throttle.abs() * MAX_MOTOR_SPEED).floor() as u32
        } else {
            (throttle.abs() * MAX_MOTOR_SPEED / 2.0).floor() as u32
        };

        let (final_motor_speed, final_direction) = if cruise_control_enabled {
            (cruise_speed, cruise_direction)
        } else {
            (joystick_motor_speed, direction)
        };

        let servo_angle = (MID_SERVO_ANGLE + (steering * MID_SERVO_ANGLE))
            .clamp(MIN_SERVO_ANGLE, MAX_SERVO_ANGLE)
            .floor() as u32;

        // =================================================================================
        //                          SENDING VALUES THROUGH CAN

        if final_motor_speed != prev_motor_speed || final_direction != prev_direction {
            controller.send_motor_command(final_motor_speed, final_direction)?;
            prev_motor_speed = final_motor_speed;
            prev_direction = final_direction;
            println!("Motor updated: {}\nDirection {}", final_motor_speed, final_direction);
        }

        if servo_angle != prev_servo_angle {
            controller.send_servo_command(servo_angle)?;
            prev_servo_angle = servo_angle;
            println!("Servo updated: {:.1}°\n Steering value: {steering}", servo_angle);
        }
    }

    Ok(next_mode)
}

fn run_autonomous_mode(
    input_rx: &mpsc::Receiver<GamepadInput>,
    controller: &MotorController,
    socket: &UdpSocket,
    perception_reader: &perception::PerceptionReader,
) -> Result<Option<DriveMode>, Box<dyn std::error::Error>> {
    println!("AUTONOMOUS MODE - Move sticks to OVERRIDE - Press B to exit");
    let mut last_ai_msg = Instant::now();
    let mut next_mode: Option<DriveMode> = None;

    let config = stanley::StanleyConfig::default();
    let mut prev_delta = 0.0;
    let dt = 0.025; // 40Hz
    let mut filtered_angle: Option<f64> = None;

    let mut target_speed: u32 = 0;
    let mut target_dir: u8 = BRAKE;
    let mut last_servo: Option<u32> = None;

    loop {
        // OVERRIDE CHECK
        if let Some(input) = recv_latest_input(input_rx, Duration::from_millis(10)) {
            if input.analog_stick_left.y.abs() > 0.2 || input.analog_stick_right.x.abs() > 0.2 {
                println!("(!) MANUEL OVERRIDE");
                next_mode = Some(DriveMode::Manual);
                break;
            }
            if input.button_b {
                println!("Exiting AUTONOMOUS mode");
                controller.stop_dc_motors()?;
                controller.reset_servo_motors()?;
                break;
            }
        }

        // 1. LER VELOCIDADE E SINAIS DA IA (UDP) - DrivaPiBrain
        let mut buf = [0u8; 128];
        while let Ok((size, _)) = socket.recv_from(&mut buf) {
            let data = String::from_utf8_lossy(&buf[..size]);
            let p: Vec<&str> = data.trim().split(',').collect();
            if p.len() >= 2 {
                target_speed = p[0].parse().unwrap_or(0).min(MAX_MOTOR_SPEED as u32);
                target_dir = p[1].parse().unwrap_or(BRAKE);
                last_ai_msg = Instant::now();
            }
        }

        // 2. LER FAIXAS E CALCULAR VOLANTE (STANLEY via SHM)
        let perception = perception_reader.read();
        let mut final_steer_deg = MID_SERVO_ANGLE as u32;
        let speed_mps = target_speed as f64 * (100.0 / 3600.0); // Simple est para o Stanley

        if perception.valid > 0 {
            let raw_cte = perception.closest_front_point as f64;
            let raw_heading = perception.heading_error as f64;

            let observation = stanley::CameraLaneObservation {
                closest_front_point_m: raw_cte,
                heading_error_rad: stanley::normalize_heading(raw_heading),
                confidence: perception.confidence as f64,
            };

            let raw_angle = stanley::compute_steering(
                &observation,
                speed_mps.max(0.5),
                prev_delta,
                dt,
                &config
            );

            let angle = match filtered_angle {
                None => raw_angle,
                Some(prev_angle) => (ALPHA * raw_angle) + ((1.0 - ALPHA) * prev_angle)
            };

            filtered_angle = Some(angle);
            prev_delta = angle;

            final_steer_deg = stanley::steering_to_servo_deg(angle, &config) as u32;

            if last_servo != Some(final_steer_deg) {
                last_servo = Some(final_steer_deg);
            }
        }

        // 3. SEGURANÇA E ATUAÇÃO
        // Se a câmara ou a IA congelar por mais de 500ms, trava o carro (Watchdog)
        if last_ai_msg.elapsed() < Duration::from_millis(500) {
            controller.send_motor_command(target_speed, target_dir)?;
            controller.send_servo_command(final_steer_deg)?;
        } else {
            println!("AI not answering (WATCHDOG)");
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break; // Sai do modo autonomo por segurança
        }

        thread::sleep(Duration::from_millis(25)); // 40Hz control loop
    }
    Ok(next_mode)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("Initializing controller...");

    let (input_rx, gamepad_handle) = spawn_gamepad_thread(GAMEPAD_DEVICE)?;
    let controller = MotorController::new(CAN_INTERFACE, CAN_ID_MOTOR, CAN_ID_SERVO)?;
    let mut prev_start_pressed = false;
    let mut prev_select_pressed = false;
    let mut requested_mode: Option<DriveMode> = None;

    // UDP para receber aceleração e travagem da IA (Python)
    let socket = UdpSocket::bind("127.0.0.1:5555")?;
    socket.set_nonblocking(true)?;

    // SHM para receber faixas e curvas do Stanley Pipeline
    let perception_reader = perception::PerceptionReader::new("/dev/shm/perception.buf")
        .map_err(|e| format!("Failed to open perception SHM: {}", e))?;

    println!("Controller ready. Press START for MANUEL mode, SELECT for Autonomous, HOME to exit.");

    loop {
        let Some(input) = recv_latest_input(&input_rx, Duration::from_millis(50)) else {
            eprintln!("Gamepad input thread disconnected");
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break;
        };

        if input.button_home {
            println!("Shutting down...");
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break;
        }

        let start_pressed = input.button_start && !prev_start_pressed;
        let select_pressed = input.button_select && !prev_select_pressed;
        prev_start_pressed = input.button_start;
        prev_select_pressed = input.button_select;

        if start_pressed {
            requested_mode = Some(DriveMode::Manual);
        } else if select_pressed {
            requested_mode = Some(DriveMode::Autonomous);
        }

        while let Some(mode) = requested_mode.take() {
            match mode {
                DriveMode::Manual => {
                    requested_mode = run_manual_mode(&input_rx, &controller)?;
                }
                DriveMode::Autonomous => {
                    requested_mode = run_autonomous_mode(&input_rx, &controller, &socket, &perception_reader)?;
                }
            }
        }
    }

    drop(input_rx);
    if gamepad_handle.join().is_err() {
        return Err(std::io::Error::other("Gamepad thread panicked").into());
    }

    Ok(())
}

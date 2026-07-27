use vehicle_control::*;

use std::time::Duration;
use std::thread;
use std::sync::mpsc;

#[derive(PartialEq, Debug)]
enum DriveMode { Manual, Autonomous }

fn spawn_gamepad_thread(
    dev_fn: &str,
) -> Result<(mpsc::Receiver<GamepadInput>, thread::JoinHandle<()>), Box<dyn std::error::Error>> {
    let mut gamepad = Gamepad::new(dev_fn).map_err(|e| format!("Failed to open gamepad: {}", e))?;

    let (input_tx, input_rx) = mpsc::channel::<GamepadInput>();
    let handle = thread::spawn(move || {
        loop {
            gamepad.update();
            if input_tx.send(*gamepad.get_input()).is_err() {
                break;
            }
            thread::sleep(Duration::from_millis(1));
        }
    });

    Ok((input_rx, handle))
}

fn recv_latest_input(
    input_rx: &mpsc::Receiver<GamepadInput>,
    timeout: Duration,
) -> Option<GamepadInput> {
    // If timeout is 0, use blocking recv_timeout with a safe 10ms floor so it 
    // actually waits for a frame instead of instantly returning Err(Timeout) -> None.
    let effective_timeout = if timeout.is_zero() {
        Duration::from_millis(10)
    } else {
        timeout
    };

    let mut latest = match input_rx.recv_timeout(effective_timeout) {
        Ok(msg) => msg,
        // Channel disconnected -> ONLY now return None!
        Err(mpsc::RecvTimeoutError::Disconnected) => return None,
        // Channel was temporarily empty -> retry once so we don't return None on a healthy channel
        Err(mpsc::RecvTimeoutError::Timeout) => {
            match input_rx.recv_timeout(Duration::from_millis(50)) {
                Ok(msg) => msg,
                _ => return None, // Truly disconnected or dead
            }
        }
    };

    // Drain queued inputs to stay on the newest frame
    while let Ok(newer) = input_rx.try_recv() {
        latest = newer;
    }

    Some(latest)
}


/*
     MODE
*/
fn run_manual_mode(
    input_rx: &mpsc::Receiver<GamepadInput>,
    controller: &MotorController,
) -> Result<Option<DriveMode>, Box<dyn std::error::Error>> {
    println!("MODE - Press B to exit");
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
    

    // =================================================================================
    //                          EXITING MODE
    
        if input.button_b {
            println!("Exiting mode");
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break;
        }

    // =================================================================================

    // =================================================================================
    //                          ENTERING AUTONOMOUS MODE
    
        if input.button_y {
            println!("Entering AUTONOMOUS mode");
            next_mode = Some(DriveMode::Autonomous);
            break;
        }

    // =================================================================================
    

    // =================================================================================
    //                          GAMEPAD INPUT VARIABLES
    
        let steering = input.analog_stick_right.x;
        let throttle = input.analog_stick_left.y;
        let max_speed = input.button_r2;
        let brake = input.button_l2;
        let d_pad: bool = input.d_pad.y as i8 != 0;

    // =================================================================================
    
    
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


    // =================================================================================
    //                          CHANGING CRUISE CONTROL SPEED VALUE
    
        if cruise_control_enabled {
            if d_pad && !prev_d_pad {
                if input.d_pad.y < 0.0 {
                    cruise_speed = cruise_speed.saturating_sub(STEP_CRUISE).max(MIN_CRUISE);
                }
                else if input.d_pad.y > 0.0 {
                    cruise_speed = cruise_speed.saturating_add(STEP_CRUISE).min(MAX_CRUISE);
                }
            }
        }
        prev_d_pad = d_pad;
        
    // =================================================================================

    
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
        if direction == BRAKE || direction == REVERSE { cruise_control_enabled = false; }
        prev_cruise_button = input.button_l3;

    // =================================================================================

    
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

    
    // =================================================================================
    //                          SENDING VALUES THROUGH CAN

        if final_motor_speed != prev_motor_speed || final_direction != prev_direction {
            controller.send_motor_command(final_motor_speed, final_direction)?;
            prev_motor_speed = final_motor_speed;
            prev_direction = final_direction;
        }

        if servo_angle != prev_servo_angle {
            controller.send_servo_command(servo_angle)?;
            prev_servo_angle = servo_angle;
        }
        
    // =================================================================================
    }

    Ok(next_mode)
}

fn run_autonomous_mode(
    input_rx: &mpsc::Receiver<GamepadInput>,
    controller: &MotorController,
    perception_reader: &perception::PerceptionReader,
    obstacle_reader: &obstacle::ObstacleReader,
) -> Result<Option<DriveMode>, Box<dyn std::error::Error>> {
    println!("AUTONOMOUS MODE - Move sticks to OVERRIDE - Press B to exit");
    let mut next_mode: Option<DriveMode> = None;
    let mut prev_d_pad = false;
    
    // Stanley configuration
    let config = stanley::StanleyConfig::default();
    
    let mut prev_delta = 0.0;
    let dt = 0.025; // 40Hz
    
    const TIMEOUT_MS: u128 = 100;
    
    let mut last_servo: Option<u32> = None;
    let mut speed: u32 = 15;
    let mut obstacle_last: bool = false;
    let mut obstacle_time: u128 = 0;
    controller.send_motor_command(speed, FORWARD)?;
    let mut speed_mps: f64;
    
    
    // =================================================================================
    
    
    // =================================================================================
    //                      AUTONOMOUS LOOP
    
    loop {
        // OVERRIDE: if human move joystick it overrides
        let Some(input) = recv_latest_input(input_rx, Duration::from_millis(0)) else {
            eprintln!("Gamepad input thread disconnected");
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break;
        };

        if input.analog_stick_left.y.abs() > 0.2 || input.analog_stick_right.x.abs() > 0.2 {
            println!("(!)  OVERRIDE");
            next_mode = Some(DriveMode::Manual);
            break;
        }
        if input.button_b {
            println!("Exiting AUTONOMOUS mode");
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break;
        }
        
        let d_pad: bool = input.d_pad.y as i8 != 0;
        let perception = perception_reader.read();
        let obstacle = obstacle_reader.read();
        
        // Watchdog: check timestamp age
        let now_ns = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)?
            .as_nanos();
        
        let age_ms = if now_ns > perception.timestamp as u128 {
            (now_ns - perception.timestamp as u128) / 1_000_000
        } else {
            0
        };

        if age_ms > TIMEOUT_MS {
            eprintln!("(!) PERCEPTION WATCHDOG TIMEOUT: {}ms", age_ms);
            controller.stop_dc_motors()?;
            controller.reset_servo_motors()?;
            break;
        }

        let now_ms = now_ns / 1_000_000;

        if !obstacle_last {
            println!("obstacle: {:?}", obstacle.sign_detected);
            if obstacle.sign_detected == 5 {
                controller.send_motor_command(0, BRAKE)?;
                obstacle_last = true;
            } else if obstacle.sign_detected != 0 && age_ms < TIMEOUT_MS {
                speed = speed.saturating_sub(STEP_CRUISE).max(MIN_CRUISE);
                controller.send_motor_command(speed, FORWARD)?;
                obstacle_time = now_ms;
                obstacle_last = true;
            }
        } else {
            if obstacle.sign_detected == 0 && age_ms - obstacle_time > 1500 {
                speed = speed.saturating_add(STEP_CRUISE).min(MAX_CRUISE);
                controller.send_motor_command(speed, FORWARD)?;
                obstacle_last = false;
                obstacle_time = 0;
            }
        }

        if d_pad && !prev_d_pad {
            if input.d_pad.y < 0.0 {
                speed = speed.saturating_sub(STEP_CRUISE).max(MIN_CRUISE);
                controller.send_motor_command(speed, FORWARD)?;

            } else if input.d_pad.y > 0.0 {
                speed = speed.saturating_add(STEP_CRUISE).min(MAX_CRUISE);
                controller.send_motor_command(speed, FORWARD)?;
            }
        }
        prev_d_pad = d_pad;
        
        speed_mps = speed as f64 * (100.0 / 3600.0);
        

        if perception.valid > 0 {

            let raw_cte = perception.closest_front_point as f64;
            let mut raw_heading = perception.heading_error as f64;
            raw_heading = if raw_heading.abs() < 0.030 {
                0.0
            } else {
                raw_heading
            };

            let observation = stanley::CameraLaneObservation {
                closest_front_point_m: raw_cte,
                heading_error_rad: stanley::normalize_heading(raw_heading),
                confidence: perception.confidence as f64,
            };
            
            let angle = stanley::compute_steering(
                &observation,
                speed_mps,
                prev_delta,
                dt,
                &config,
            );

            prev_delta = angle;

            let servo_deg = stanley::steering_to_servo_deg(angle, &config) as u32;

            if last_servo != Some(servo_deg) {
                controller.send_servo_command(servo_deg)?;
                last_servo = Some(servo_deg);
            }
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

    let perception_reader = perception::PerceptionReader::new("/dev/shm/perception.buf")?;
    let obstacle_reader = obstacle::ObstacleReader::new("/dev/shm/obstacle.buf")?;

    println!("Controller ready. Press START to enter  mode, SELECT for Autonomous, HOME to exit.");

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
                    requested_mode = run_autonomous_mode(&input_rx, &controller, &perception_reader, &obstacle_reader)?;
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

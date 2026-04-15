

use std::fs::File;
use std::io::{Read, ErrorKind};
use std::os::unix::io::AsRawFd;
use std::collections::HashMap;
use std::path::Path;
use socketcan::{CanFrame, CanSocket, StandardId, EmbeddedFrame};
use socketcan::Socket;
use std::{thread, time::Duration};

/* CAN Protocol Constants */
const CAN_ID_MOTOR: u16 = 44;
const CAN_ID_SERVO: u16 = 45;
const CAN_INTERFACE: &str = "vcan0";

/* Motor Constants */
const MAX_MOTOR_SPEED: f64 = 90.0;

const BACKWARD: u8 = 0;
const FORWARD: u8 = 1;
const BRAKE: u8 = 2;
const NEUTRAL: u8 = 3;

/* Servo Constants */
const MAX_SERVO_ANGLE: f64 = 105.0;
const MIN_SERVO_ANGLE: f64 = 75.0;
const MID_SERVO_ANGLE: f64 = 90.0;
const SERVO_RANGE: f64 = 15.0;  // Distance from center to min/max

/* Gamepad Constants */
const GAMEPAD_DEVICE: &str = "/dev/input/js0";
const JOYSTICK_EVENT_SIZE: usize = 8;
const JS_EVENT_BUTTON: u8 = 0x01;
const JS_EVENT_AXIS: u8 = 0x02;
const JS_EVENT_INIT: u8 = 0x80;

static mut CRUISE_CONTROL_STATUS: bool = false;

#[derive(Default, Debug, Clone, Copy)]
pub struct Vector2f {
    x: f64,
    y: f64,
}

#[derive(Default, Debug)]
pub struct GamepadInput {
    analog_stick_left: Vector2f,
    analog_stick_right: Vector2f,
    d_pad: Vector2f,
    button_l1: bool,
    button_l2: bool,
    button_r1: bool,
    button_r2: bool,
    button_x: bool,
    button_a: bool,
    button_b: bool,
    button_y: bool,
    button_select: bool,
    button_start: bool,
    button_home: bool,
    button_l3: bool,
    button_r3: bool,
}

pub struct Joystick {
    axis_states: HashMap<u8, f64>,
    button_states: HashMap<u8, bool>,
    jsdev: File,
}

impl Joystick {
    fn new(dev_fn: &str) -> Result<Self, std::io::Error> {
        if !Path::new(dev_fn).exists() {
            return Err(std::io::Error::new(
                ErrorKind::NotFound,
                format!("Joystick device not found: {}", dev_fn),
            ));
        }

        let file = File::open(dev_fn)?;
        
        // Set file descriptor to non-blocking mode using fcntl
        let fd = file.as_raw_fd();
        unsafe {
            use std::os::raw::c_int;
            const F_GETFL: c_int = 3;
            const F_SETFL: c_int = 4;
            const O_NONBLOCK: c_int = 2048;
            
            unsafe extern "C" {
                fn fcntl(fd: c_int, cmd: c_int, ...) -> c_int;
            }
            
            let flags = fcntl(fd, F_GETFL, 0);
            fcntl(fd, F_SETFL, flags | O_NONBLOCK);
        }
        
        Ok(Self {
            axis_states: HashMap::new(),
            button_states: HashMap::new(),
            jsdev: file,
        })
    }

    fn poll(&mut self) -> Option<JoystickEvent> {
        let mut buf = [0u8; JOYSTICK_EVENT_SIZE];
        
        match self.jsdev.read(&mut buf) {
            Ok(JOYSTICK_EVENT_SIZE) => {
                let _timestamp = u32::from_le_bytes([buf[0], buf[1], buf[2], buf[3]]);
                let value = i16::from_le_bytes([buf[4], buf[5]]);
                let event_type = buf[6];
                let number = buf[7];

                // Ignore initialization events
                if event_type & JS_EVENT_INIT != 0 {
                    return None;
                }

                if event_type & JS_EVENT_BUTTON != 0 {
                    let pressed = value != 0;
                    self.button_states.insert(number, pressed);
                    return Some(JoystickEvent::Button { number, pressed });
                }

                if event_type & JS_EVENT_AXIS != 0 {
                    let normalized_value = (value as f64) / 32767.0;
                    self.axis_states.insert(number, normalized_value);
                    return Some(JoystickEvent::Axis { number, value: normalized_value });
                }
            }
            Ok(_) => {
                eprintln!("Warning: Incomplete joystick read");
            }
            Err(e) if e.kind() == ErrorKind::WouldBlock => {
                // Non-blocking read with no data available
            }
            Err(e) => {
                eprintln!("Error reading joystick: {}", e);
            }
        }

        None
    }
}

#[derive(Debug)]
enum JoystickEvent {
    Button { number: u8, pressed: bool },
    Axis { number: u8, value: f64 },
}

pub struct Gamepad {
    joystick: Joystick,
    input: GamepadInput,
}

impl Gamepad {
    fn new(dev_fn: &str) -> Result<Self, std::io::Error> {
        let js = Joystick::new(dev_fn)?;
        Ok(Self {
            joystick: js,
            input: GamepadInput::default(),
        })
    }

    fn update(&mut self) {
        if let Some(event) = self.joystick.poll() {
            match event {
                JoystickEvent::Axis { number, value } => {
                    match number {
                        0 => self.input.analog_stick_left.x = value,
                        1 => self.input.analog_stick_left.y = -value,
                        2 => self.input.button_l2 = value == 1.0,
                        3 => self.input.analog_stick_right.x = value,
                        4 => self.input.analog_stick_right.y = -value,
                        5 => self.input.button_r2 = value == 1.0,
                        6 => self.input.d_pad.x = value,
                        7 => self.input.d_pad.y = -value,
                        _ => {}
                    }
                }
                JoystickEvent::Button { number, pressed } => {
                    match number {
                        0 => self.input.button_a = pressed,
                        1 => self.input.button_b = pressed,
                        2 => self.input.button_x = pressed,
                        3 => self.input.button_y = pressed,
                        4 => self.input.button_l1 = pressed,
                        5 => self.input.button_r1 = pressed,
                        6 => self.input.button_select = pressed,
                        7 => self.input.button_start = pressed,
                        8 => self.input.button_home = pressed,
                        9 => self.input.button_l3 = pressed,
                        10 => self.input.button_r3 = pressed,
                        _ => {}
                    }
                }
            }
        }
    }

    fn get_input(&self) -> &GamepadInput {
        &self.input
    }
}

struct MotorController {
    socket: CanSocket,
    motor_id: StandardId,
    servo_id: StandardId,
}

impl MotorController {
    fn new(interface: &str, motor_can_id: u16, servo_can_id: u16) -> Result<Self, Box<dyn std::error::Error>> {
        let socket = CanSocket::open(interface)?;
        let motor_id = StandardId::new(motor_can_id)
            .ok_or_else(|| format!("Invalid motor CAN ID: {}", motor_can_id))?;
        let servo_id = StandardId::new(servo_can_id)
            .ok_or_else(|| format!("Invalid servo CAN ID: {}", servo_can_id))?;

        Ok(Self { socket, motor_id, servo_id })
    }

    fn send_motor_command(&self, speed: u32, mut direction: u8) -> Result<(), Box<dyn std::error::Error>> {
        // Build CAN frame: [speed][direction] = 5 bytes

        if direction == NEUTRAL {direction = FORWARD;} // TEMPORARY
        
        let speed_bytes = speed.to_le_bytes();
        let direction_bytes = direction.to_le_bytes();
        let data = [
            speed_bytes[0], speed_bytes[1], speed_bytes[2], speed_bytes[3],
            direction_bytes[0],
        ];

        let frame = CanFrame::new(self.motor_id, &data)
            .ok_or("Failed to create motor CAN frame")?;
        
        self.socket.write_frame(&frame)?;
        Ok(())
    }

    fn send_servo_command(&self, angle_deg: u32) -> Result<(), Box<dyn std::error::Error>> {
        // Build CAN frame: [angle_f32] = 4 bytes (no padding needed)
        let angle_bytes = angle_deg.to_le_bytes();
        let data = [
            angle_bytes[0], angle_bytes[1], angle_bytes[2], angle_bytes[3],
            0,0,0,0,
        ];

        let frame = CanFrame::new(self.servo_id, &data)
            .ok_or("Failed to create servo CAN frame")?;
        
        self.socket.write_frame(&frame)?;
        Ok(())
    }

    fn stop_dc_motors(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.send_motor_command(0, BRAKE)
    }
    fn stop_servo_motors(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.send_servo_command(90)
    }    
}






fn run_manual_mode(gamepad: &mut Gamepad, controller: &MotorController) -> Result<(), Box<dyn std::error::Error>> {
    println!("MANUEL MODE - Press B to exit");

    // INIT OF VALUES
    
    // Track previous values to detect changes
    let mut prev_motor_speed: u32 = 0;
    let mut prev_servo_angle:  u32 = 90;
    let mut direction: u8 = BRAKE;
    
    // Threshold for detecting meaningful changes
    const MOTOR_THRESHOLD: u32 = 2;  // Only send if change > 2 counts

    let mut cruise_control: bool;
    unsafe {
        CRUISE_CONTROL_STATUS = false;
    }


    // Starting of the MANUEL loop
    loop {
        gamepad.update();
        let input = gamepad.get_input();
        
    // ================================================================
    //                      EXIT CONDITION
        
        if input.button_b {
            println!("Exiting MANUEL mode");
            controller.stop_dc_motors()?;
            controller.stop_servo_motors()?;
            break;
        }
        
    // ================================================================
    
    // ================================================================
    //                      CONTROL INPUTS
    
        let steering = input.analog_stick_right.x;   // Right stick X: -1.0 to 1.0
        let throttle = input.analog_stick_left.y;    // Left stick Y: -1.0 to 1.0
        let max_speed = input.button_r2;
        let brake = input.button_l2;
        cruise_control = input.button_l3;

    // ================================================================
    //                  DEFINING DIRECTION

        if brake{
            direction = BRAKE;
        } else if throttle > 0.0{
            direction = FORWARD;
        } else if throttle < 0.0{
            direction = BACKWARD;
        } else {
            direction = NEUTRAL;
        }

    // ================================================================
    //                  ACTIVATING CRUISE CONTROL
    
        unsafe {
            while cruise_control && (direction == FORWARD || CRUISE_CONTROL_STATUS){ 
                gamepad.update();
                if !gamepad.get_input().button_l3{
                    CRUISE_CONTROL_STATUS = !CRUISE_CONTROL_STATUS;
                    break ;   
                }
            }
        }
        
    // ================================================================

    // ================================================================
    //                  CALCULATE SERVO AND DC MOTORS

        let motor_speed: u32;
        if max_speed{ motor_speed = (throttle.abs() * MAX_MOTOR_SPEED).floor() as u32; }
        else { motor_speed = (throttle.abs() * MAX_MOTOR_SPEED / 2.0).floor() as u32; }

        // Map steering (-1.0 to 1.0) to servo angle (75 to 105), center at 90
        let servo_angle = (MID_SERVO_ANGLE + (steering * SERVO_RANGE)).clamp(MIN_SERVO_ANGLE, MAX_SERVO_ANGLE).floor() as u32;

    // ================================================================
    
    // ================================================================
    // Send motor command only if value changed significantly and cruise control is disabled
        unsafe {
            if !CRUISE_CONTROL_STATUS {
                if motor_speed != prev_motor_speed {
                    controller.send_motor_command(motor_speed, direction)?;
                    prev_motor_speed = motor_speed;
                    println!("Motor updated: {}\nDirection {}", motor_speed, direction);
                }
            }
            else {
                
            }
        }

    // ================================================================
        // Send servo command only if value changed significantly
        if servo_angle != prev_servo_angle {
            controller.send_servo_command(servo_angle)?;
            prev_servo_angle = servo_angle;
            println!("Servo updated: {:.1}°\n Steering value: {steering}", servo_angle);
        }

        // Small delay to avoid busy-waiting
        thread::sleep(Duration::from_millis(1));
    }

    Ok(())
}










fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("Initializing controller...");

    // Initialize gamepad
    let mut gamepad = Gamepad::new(GAMEPAD_DEVICE)
        .map_err(|e| format!("Failed to open gamepad: {}", e))?;

    // Initialize CAN controller
    let controller = MotorController::new(CAN_INTERFACE, CAN_ID_MOTOR, CAN_ID_SERVO)?;

    println!("Controller ready. Press START to enter manual mode, SELECT to exit.");

    // Main state machine loop
    loop {
        gamepad.update();
        let input = gamepad.get_input();

        // Check for exit
        if input.button_select {
            println!("Shutting down...");
            controller.stop_dc_motors()?;
            controller.stop_servo_motors()?;
            break;
        }

        // Check for manual mode entry
        if input.button_start {
            run_manual_mode(&mut gamepad, &controller)?;
        }

        thread::sleep(Duration::from_millis(10));
    }

    Ok(())
}

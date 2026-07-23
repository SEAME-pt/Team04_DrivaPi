/* CAN Protocol pub constants */
pub const CAN_ID_MOTOR: u16 = 44;
pub const CAN_ID_SERVO: u16 = 45;
pub const CAN_INTERFACE: &str = "can1";

/* Motor pub constants */
pub const MAX_MOTOR_SPEED: f64 = 90.0;

/* Cruise Control pub constants */
pub const MIN_CRUISE: u32 = 1;
pub const MAX_CRUISE: u32 = 90;
pub const STEP_CRUISE: u32 = 5;

/* Direction pub constants */
pub const NEUTRAL: u8 = 0;
pub const FORWARD: u8 = 1;
pub const REVERSE: u8 = 2;
pub const BRAKE: u8 = 3;

/* Servo pub constants */
pub const MAX_SERVO_ANGLE: f64 = 180.0;
pub const MIN_SERVO_ANGLE: f64 = 0.0;
pub const MID_SERVO_ANGLE: f64 = 90.0;

/* Gamepad pub constants */
pub const GAMEPAD_DEVICE: &str = "/dev/input/js0";
pub const JOYSTICK_EVENT_SIZE: usize = 8;
pub const JS_EVENT_BUTTON: u8 = 0x01;
pub const JS_EVENT_AXIS: u8 = 0x02;
pub const JS_EVENT_INIT: u8 = 0x80;

/* EMA pub constants */
pub const SPIKE_THRESHOLD_RAD: f64 = 0.45; //original 0.15
pub const ALPHA: f64 = 0.80;

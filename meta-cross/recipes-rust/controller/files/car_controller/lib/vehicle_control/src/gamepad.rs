use crate::Vector2f;
use crate::constants::*;

use std::collections::HashMap;
use std::fs::File;
use std::path::Path;
use std::io::{ ErrorKind, Read };
use std::os::fd::AsRawFd;


/* Gamepad Input Struct 
	-> Struct serves the point of storing the values for each button in the GamePad
*/
#[derive(Default, Debug, Clone, Copy)]
pub struct GamepadInput {
	pub d_pad:				Vector2f,
	
	pub analog_stick_left:	Vector2f,
	pub analog_stick_right:	Vector2f,
	
	pub button_l1:			bool,
	pub button_l2:			bool,
	pub button_l3:			bool,
	pub button_r1:			bool,
	pub button_r2:			bool,
	pub button_r3:			bool,

	pub button_x:			bool,
	pub button_a:			bool,
	pub button_b:			bool,
	pub button_y:			bool,
	
	pub button_select:		bool,
	pub button_start:		bool,
	pub button_home:		bool,
}

/* JoyStick Struct
	-> Struct to store the addresses for each button in the GamePad 
*/
pub struct Joystick {
	axis_states: HashMap<u8, f64>,
	button_states: HashMap<u8, bool>,
	jsdev: File,
}

#[derive(Debug)]
pub enum JoystickEvent {
	Button { number: u8, pressed: bool },
	Axis { number: u8, value: f64 },
}

impl Joystick {
	pub fn new(dev_fn: &str) -> Result<Self, std::io::Error> {
		if !Path::new(dev_fn).exists() {
			return Err(std::io::Error::new(
				ErrorKind::NotFound,
				format!("Joystick device not found: {}", dev_fn),
			));
		}

		let file = File::open(dev_fn)?;

//================================================================================================
//================================================================================================
    
	/* 
		Unsafe code block, because we are using `C` function fcntl
		Set file descriptor to non-blocking mode using fcntl
	*/
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
//================================================================================================
//================================================================================================

		Ok(Self {
			axis_states: HashMap::new(),
			button_states: HashMap::new(),
			jsdev: file,
		})
	}

    pub fn poll(&mut self) -> Option<JoystickEvent> {
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
                    return Some(JoystickEvent::Axis {
                        number,
                        value: normalized_value,
                    });
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

pub struct Gamepad {
    joystick: Joystick,
    input: GamepadInput,
}

impl Gamepad {
    pub fn new(dev_fn: &str) -> Result<Self, std::io::Error> {
        let js = Joystick::new(dev_fn)?;
        Ok(Self {
            joystick: js,
            input: GamepadInput::default(),
        })
    }

    pub fn update(&mut self) {
        if let Some(event) = self.joystick.poll() {
            match event {
                JoystickEvent::Axis { number, value } => match number {
                    0 => self.input.analog_stick_left.x = value,
                    1 => self.input.analog_stick_left.y = -value,
                    2 => self.input.button_l2 = value == 1.0,
                    3 => self.input.analog_stick_right.x = value,
                    4 => self.input.analog_stick_right.y = -value,
                    5 => self.input.button_r2 = value == 1.0,
                    6 => self.input.d_pad.x = value,
                    7 => self.input.d_pad.y = -value,
                    _ => {}
                },
                JoystickEvent::Button { number, pressed } => match number {
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
                },
            }
        }
    }

    pub fn get_input(&self) -> &GamepadInput {
        &self.input
    }
}

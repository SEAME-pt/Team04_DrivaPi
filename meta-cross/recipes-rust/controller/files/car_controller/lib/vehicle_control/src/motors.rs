use crate::constants::BRAKE;
use socketcan::{Socket, CanFrame, CanSocket, EmbeddedFrame, StandardId};

pub struct MotorController {
    socket: CanSocket,
    motor_id: StandardId,
    servo_id: StandardId,
}

impl MotorController {
    pub fn new(
        interface: &str,
        motor_can_id: u16,
        servo_can_id: u16,
    ) -> Result<Self, Box<dyn std::error::Error>> {
        let socket = CanSocket::open(interface)?;
        let motor_id = StandardId::new(motor_can_id)
            .ok_or_else(|| format!("Invalid motor CAN ID: {}", motor_can_id))?;
        let servo_id = StandardId::new(servo_can_id)
            .ok_or_else(|| format!("Invalid servo CAN ID: {}", servo_can_id))?;

        Ok(Self {
            socket,
            motor_id,
            servo_id,
        })
    }

    pub fn send_motor_command(
        &self,
        speed: u32,
        direction: u8,
    ) -> Result<(), Box<dyn std::error::Error>> {
        // Build CAN frame: [speed][direction] = 5 bytes

        let speed_bytes = speed.to_le_bytes();
        let direction_bytes = direction.to_le_bytes();
        let data = [
            speed_bytes[0],
            speed_bytes[1],
            speed_bytes[2],
            speed_bytes[3],
            direction_bytes[0],
        ];

        let frame =
            CanFrame::new(self.motor_id, &data).ok_or("Failed to create motor CAN frame")?;

        self.socket.write_frame(&frame)?;
        Ok(())
    }

    pub fn send_servo_command(&self, angle_deg: u32) -> Result<(), Box<dyn std::error::Error>> {
        // Build CAN frame: [angle_f32] = 4 bytes (no padding needed)
        let angle_bytes = angle_deg.to_le_bytes();
        let data = [
            angle_bytes[0],
            angle_bytes[1],
            angle_bytes[2],
            angle_bytes[3],
        ];

        let frame =
            CanFrame::new(self.servo_id, &data).ok_or("Failed to create servo CAN frame")?;

        self.socket.write_frame(&frame)?;
        Ok(())
    }

    pub fn stop_dc_motors(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.send_motor_command(0, BRAKE)
    }
    pub fn reset_servo_motors(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.send_servo_command(90)
    }
}

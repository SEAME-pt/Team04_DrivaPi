#include <Servo.h>

// --- MOTOR A PINS (First Motor) ---
const int AIN1 = 10;
const int AIN2 = 9;
const int PWMA = 8;

// --- MOTOR B PINS (Second Motor) ---
const int BIN1 = 12;
const int BIN2 = 11;
const int PWMB = 13; /

// --- SERVO PIN ---
Servo myServo;
const int servoPin = 7;

void setup() 
{
  // Initialize Motor A Pins
  pinMode(AIN1, OUTPUT);
  pinMode(AIN2, OUTPUT);
  pinMode(PWMA, OUTPUT);

  // Initialize Motor B Pins
  pinMode(BIN1, OUTPUT);
  pinMode(BIN2, OUTPUT);
  pinMode(PWMB, OUTPUT);

  // Attach the servo on pin 7
  myServo.attach(servoPin);
}

void loop() 
{
  // --- STEP 1: Move Both Motors Forward & Move Servo to 0 degrees ---
  moveMotors(200, true);
  myServo.write(0);
  delay(2000);

  // --- STEP 2: Stop Both Motors & Move Servo to 90 degrees ---
  stopMotors();
  myServo.write(90);
  delay(1000);

  // --- STEP 3: Move Both Motors Backward & Move Servo to 180 degrees ---
  moveMotors(200, false);
  myServo.write(180);
  delay(2000);

  // --- STEP 4: Stop Both Motors & Move Servo back to 90 degrees ---
  stopMotors();
  myServo.write(90);
  delay(1000);
}

// Helper function to control BOTH TB6612FNG DC Motors
void moveMotors(int speed, boolean forward)
{
  // Set speed (0 to 255) for both channels
  analogWrite(PWMA, speed);
  analogWrite(PWMB, speed);

  if (forward) 
  {
    digitalWrite(AIN1, HIGH);
    digitalWrite(AIN2, LOW);
    digitalWrite(BIN1, HIGH);
    digitalWrite(BIN2, LOW);
  } 
  else 
  {
    digitalWrite(AIN1, LOW);
    digitalWrite(AIN2, HIGH);
    digitalWrite(BIN1, LOW);
    digitalWrite(BIN2, HIGH);
  }
}


void stopMotors() 
{

  digitalWrite(AIN1, LOW);
  digitalWrite(AIN2, LOW);
  digitalWrite(BIN1, LOW);
  digitalWrite(BIN2, LOW);
  
  analogWrite(PWMA, 0);
  analogWrite(PWMB, 0);
}

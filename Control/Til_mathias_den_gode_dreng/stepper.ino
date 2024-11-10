//#include <stdio.h>
#include <AccelStepper.h>

// Variables
#define dir_pin 4
#define step_pin 6

AccelStepper stepper(AccelStepper::DRIVER, step_pin, dir_pin);

void setup() {
  pinMode(dir_pin, OUTPUT);
  pinMode(step_pin, OUTPUT);
  resetPins(); //sets pins to default
  Serial.begin(9600);
}

void loop() {
  Serial.println("Input steps");

  while (Serial.available() == 0) {
    delay(10);
  }

  int serial_beam_steps = Serial.parseInt();

  while (Serial.available() > 0) {
    Serial.read();  // Clear any leftover characters, like '\n'
  }
  beamScan(serial_beam_steps);
}

bool Delay(int delay_counter) {

  static unsigned long prev_millis = 0;
  unsigned long curr_millis = millis();
  if (curr_millis - prev_millis >= delay_counter) {
    prev_millis = curr_millis;
    return true;
  }
  return false;
}

void stepFwdBwd(int dir, int steps) {
  digitalWrite(dir_pin, dir); //dir = 0(FWD), dir = 1(BWD)
  for (uint16_t x = 0; x < steps; x++) //Number of steps
  {
    digitalWrite(step_pin, HIGH); //Trigger one step forward
    delay(1);
    digitalWrite(step_pin, LOW); //Pull step pin low so it can be triggered again
    delay(1);
  }
}

void beamScan(int beam_steps) {
  for (int x = 0; x < 10; x++) {
    if (x < 5) {
      stepFwdBwd(0, beam_steps); //Steps forward
      Serial.print("Moving "); Serial.print(beam_steps); Serial.println(" steps forward."); Serial.println("");
      delay(100);
    } else {
      stepFwdBwd(1, beam_steps); //Steps backward
      Serial.print("Moving "); Serial.print(beam_steps); Serial.println(" steps backward."); Serial.println("");
      delay(100);
    }
  }
}

void serial_fwd_bwd() {
  while (Serial.available() == 0) {
    // Optionally add a small delay to reduce CPU usage while waiting
    delay(10);
  }
  //Read direction and steps from serial monitor
  int dir = Serial.parseInt();
  Serial.print("Dir: "); Serial.println(dir);
  int steps = Serial.parseInt();
  Serial.print("Steps: "); Serial.println(steps);

  // Flush the serial buffer to clear any extra characters
  while (Serial.available() > 0) {
    Serial.read();  // Clear any leftover characters, like '\n'
  }

  if (steps != 0) {
    if (dir == 0) {
      stepFwdBwd(dir, steps); //Step forward
    }
    else if (dir == 1) {
      stepFwdBwd(dir, steps); //Step backward
    }
    else {
      Serial.println("Du er sådan en god dreng Snorre");
    }
  }
}

void resetPins() {
  digitalWrite(dir_pin, LOW);
  digitalWrite(step_pin, LOW);
}


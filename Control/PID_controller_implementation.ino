// PID gains
float Kp = 1.0;  // Proportional gain
float Ki = 0.5;  // Integral gain
float Kd = 0.1;  // Derivative gain

// Sampling time (in seconds)
float Ts = 0.1;
float Tf = 1;

// Variables for PID
float error = 0, prev_error = 0, integral = 0, derivative = 0, filtered_derivative = 0;
float alpha = Ts/Tf; // Smoothing factor for derivative filter (0 < alpha <= 1)
float prev_filtered_derivative = 0;
float output = 0;

// Setpoint and measured value
float setpoint = 1.0; // Desired value
float measured_value = 0.0; // Sensor feedback

void setup() {
  Serial.begin(9600);
}

void loop() {
  // Simulate sensor reading (replace with actual sensor input)
  measured_value = analogRead(A0) / 1023.0; // Example: 0-1 normalized

  // Calculate error  
  error = setpoint - measured_value;

  // PID calculations
  integral += error * Ts;                       // Integral term

  // Apply low-pass filter to the derivative
  filtered_derivative = alpha * error + (1 - alpha) * prev_filtered_derivative;

  // Calculate raw derivative term
  derivative = (filtered_derivative - prev_filtered_derivative) / Ts; // Derivative term

  // PID output using filtered derivative
  output = Kp * error + Ki * integral + Kd * derivative;

  // Actuator command (replace with actual actuator code)
  analogWrite(9, constrain(output, 0, 255)); // Example: PWM output

  // Update previous values for next iteration
  prev_error = error;
  prev_filtered_derivative = filtered_derivative;

  // Wait for next sampling period
  delay(Ts * 1000); // Convert Ts to milliseconds

  // Debugging information
  Serial.print("Setpoint: "); Serial.print(setpoint);
  Serial.print(" Measured: "); Serial.print(measured_value);
  Serial.print(" Output: "); Serial.println(output);
}

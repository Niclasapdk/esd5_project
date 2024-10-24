# Motor model 

The purpose for modeling the motor is to find the motors transfer function $H(s) = \frac{\omega_s (s)}{E_a(s)}$ with the input voltage given the output speed of the motor

Where:
- $\omega_s(s)$ = motor speed $[\frac{rad}{s}]$
- $V_s(s)$ = input voltage [V]

## Electrical model

The electrical model for the motor is shown in the figure below: 

<figure>
<img src="Figures\Electrical_motor.drawio.png" width="400" height="250">
<figcaption>Electrical circuit for dc-motor setup</figcaption>
</figure>

And the electrical relationship with the use of KVL can be written as: 

$$ V(t) = i(t)\cdot i + L\frac{di(t)}{dt} + e_a  $$

Where: 

- V(t) = Input voltage for the motor
- i = The current in the motor
- R = The impedance of the motor
- L = The inductance of the motor
- $e_a$ = is the back emf of the motor


$e_a$ can also be written as: 

$$ e_a = k_f \cdot \frac{d\theta_m}{dt} $$

Where: 

- $k_f$ = back EMF constant of the motor 
- $\frac{d\theta_m}{dt}$ = Angular velocity of the motor 

Replacing the new term of $e_a$ gives the following: 

$$ V(t) = i(t)\cdot i + L\frac{di(t)}{dt} + k_f \cdot \frac{d\theta_m}{dt} $$

This expression can be rewritten as: 

$$L\frac{di(t)}{dt} = V(t) - i(t)R - k_f \cdot \frac{d\theta_m}{dt}$$

$\Downarrow$

$$\frac{di(t)}{dt} = \frac{1}{L}(V(t) - i(t)R - k_f \cdot \frac{d\theta_m}{dt})$$

# Newtons second law for rotation

Newtons second law for rotation states that the sum of all torques acting on an object is equal to the moment of ineria J times the angular acceleration $\alpha$: 

$$\sum\tau = J \cdot \alpha$$

Where: 

- $\sum\tau$ = The sum of torques acting oppon the object
- J = moment of inertia of the pedestal
- $\alpha$ = is the angular velocity $\frac{d^2\theta}{dt^2}$

Damping Torque

$\tau_{damping}$ = $K_d\cdot\frac{d\theta}{dt}$

Where: 

- $K_d$ = Is the damping factor pedestal
- $\frac{d\theta}{dt}$ = is the angular velocity


The sum of torque: 

The sum of torque is described as: 

$$\tau_{total} = \tau_{motor} - K_d\cdot\frac{d\theta}{dt}$$

$\Downarrow$

$$\tau_{motor} - K_d\cdot\frac{d\theta}{dt} = J\cdot\frac{d^2\theta}{dt^2}$$

$\Downarrow$

$$\frac{d^2\theta}{dt^2}=\frac{1}{J}(\tau_{motor} - K_d\cdot\frac{d\theta}{dt})$$
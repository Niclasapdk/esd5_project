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



# State Space of transferfunction
To use matlabs function of system identification the transfer function for the motor with load given in eq~\ref{} needs to be on state space form and need to be expressed as: 

$$\dot{x}(t) = A\bold{x}(t) + B\bold{u}(t) \\
   y(t) = C\bold{x}(t) + D\bold{u}(t)$$

Where

- $\bold{x}(t)$ is the state vector
- $\bold{u}(t)$ is the input
- $y(t)$ is the output
- A, B, C and D are matrices that need to be derived

From the found transfer function the denominator can be expressed as a thrid-order polynomial: 

$$L_aJ_ms^3 + (R_aJ_m + L_ab_m)s^2 + (R_ab_m + K_tK_b)s$$

Where: 

$$a_3 = L_aJ_m \text{  } a_2 = R_aJ_m + L_ab_m \text{  } a_1 = R_ab_m + K_tK_b$$

Which gives a transferfunction of: 

$$\frac{\Theta_{m}(s)}{V_a(s)} = \frac{K_t}{a_3s^3+a_2s^2+a_1s}$$

Because its a third order system there can be defined 3 state variables: 

$$x_1 = \Theta_m \text{ , } x_2 = \dot{\Theta_m} \text{ , } x_3 = \ddot{\Theta_m}$$

Which means that $x_1$ is the position, $x_2$ is the velocity and $x_3$ is the acceleration.

The time derivatives of the state variables can be expressed as:

For $x_1$ : 

$$\dot{x}_1 = \frac{d}{dt}\Theta_m = \dot{\Theta}_m$$

For $x_2$ : 

$$\dot{x}_2 = \frac{d}{dt}\dot{\Theta}_m = \ddot{\Theta}_m$$

For $\dot{x}_3$ this derivative need to be expressed in terms of exsisting state variables $x_1,x_2,x_3$ and the input voltage $V_a$. 

The transfer function from eq~\ref{} can be transformed into a differential equation in the time domain by multiplying both sides with the denominator: 

$$a_3s^3\Theta_m(s) + a_2s^2\Theta_m(s)+a_1s\Theta_m(s) = K_tV_a(s)$$

Taking the inverse laplace transform gives: 

$$a_3\frac{d^3\Theta_m}{dt^3} + a_2\frac{d^2\Theta_m}{dt^2} + a_1\frac{d\Theta_m}{dt} = K_tV_a(t)$$

Then substituting the state variables:

$$\frac{d\Theta_m}{dt} = x_2 \\
  \frac{d^2\Theta_m}{dt^2} = x_3 \\
  \frac{d^3\Theta_m}{dt^3} = \dot{x}_3
$$

The differential equation will be: 

$$a_3\dot{x}_3 + a_2x_3+a_1x_2 = K_tV_a$$

Then solving for $\dot{x}_3$ gives: 

$$\dot{x_3} = -\frac{a_2}{a_3}x_3 - \frac{a_1}{a_3}x_2 + \frac{K_t}{a_3} V_a $$

Which means there is the following equation for $\dot{x}_1,\dot{x}_2,\dot{x}_3$:

$$\dot{x}_1 = x_2 \\
  \dot{x}_2 = x_3 \\
  \dot{x}_3 = -\frac{a_2}{a_3}x_3 - \frac{a_1}{a_3}x_2 + \frac{K_t}{a_3} V_a$$

Which on matrix form can be written as:

$$\dot{x}_3 = \begin{bmatrix} \dot{x}_1 \\ \dot{x}_2 \\ \dot{x}_3  \end{bmatrix} = \begin{bmatrix}
    0 & 1 & 0 \\ 0 & 0 & 1 \\ 0 & -\frac{a_1}{a_3} & -\frac{a_2}{a_3} 
\end{bmatrix} \begin{bmatrix}
    x_1 \\ x_2 \\ x_3
\end{bmatrix} + \begin{bmatrix}
    0 \\ 0 \\ \frac{K_t}{a_3}
\end{bmatrix} V_a$$

The output y can be expressed as:

$$y = \Theta_m = \begin{bmatrix}
    0 & 1 & 0
\end{bmatrix} \begin{bmatrix}
    x_1 \\ x_2 \\ x_3 
\end{bmatrix}$$

Which gives the following state-space representation: 

$$\bold{A} = \begin{bmatrix}
    0 & 1 & 0 \\ 0 & 0 & 1 \\ 0 & -\frac{a_1}{a_3} & -\frac{a_2}{a_3} 
\end{bmatrix}, \bold{B} = \begin{bmatrix}
    0 \\ 0 \\ \frac{K_t}{a_3}
\end{bmatrix}, \bold{C} = \begin{bmatrix}
    0 & 1 & 0
\end{bmatrix} \bold{D} = [0] $$
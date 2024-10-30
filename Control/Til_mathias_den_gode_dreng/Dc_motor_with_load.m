function [A, B, C, D, K, x0] = dc_motor_with_load(params, T, aux)

    Jm = params(1);    % Inertia
    bm = params(2);    % Damping

    Kt = aux(1);          % Motor torque constant
    Ra = aux(2);          % Armature resistance
    Kb = aux(3);          % Back EMF constant

    A = - (bm + (Kt * Kb) / Ra) / Jm;
    B = Kt / (Ra * Jm);
    C = 1;
    D = 0;

    % Disturbance matrix and initial states (set to zero if not estimated)
    K = 0;
    x0 = 0;
end
`resetall
`timescale 1ns / 1ps
`default_nettype none

module cbf_power_estimator
#(
	parameter MOVING_AVERAGE_SNAPSHOT_COUNT = 8, // should be some 2^x
	parameter WORD_LENGTH_I_AND_Q = 16, // should be even number of bytes
	parameter WORD_LENGTH_IN = WORD_LENGTH_I_AND_Q*8, // should be even number of bytes
	parameter WORD_LENGTH_POWER_MOMENTARY = ((WORD_LENGTH_I_AND_Q*2)+8)*2,
	parameter WORD_LENGTH_POWER = WORD_LENGTH_POWER_MOMENTARY+MOVING_AVERAGE_SNAPSHOT_COUNT,
	parameter WORD_LENGTH_OUT = WORD_LENGTH_POWER, // should be even number of bytes
	// Input constants in degrees
	parameter real steering_angle_deg = 40,
	parameter real angle_calibration0_deg = 0,
	parameter real angle_calibration1_deg = 0,
	parameter real angle_calibration2_deg = 0,
	parameter real angle_calibration3_deg = 0
)
(
	input clk,
	input rst,
	// Input axis
	input [WORD_LENGTH_IN-1 : 0] s_axis_tdata,
	input  s_axis_tvalid,
	output s_axis_tready, // always high
	// Output axis
	output [WORD_LENGTH_OUT-1 : 0] m_axis_tdata,
	output m_axis_tvalid,
	input  m_axis_tready // ignored
);

/////////////////////////////////
// Steering vector calculation //
/////////////////////////////////

// Define constants
parameter real PI = 3.14159265358979323846;

// Convert degrees to radians
parameter real steering_angle_rad = steering_angle_deg * (PI / 180.0);
parameter real angle_calibration0_rad = angle_calibration0_deg * (PI / 180.0);
parameter real angle_calibration1_rad = angle_calibration1_deg * (PI / 180.0);
parameter real angle_calibration2_rad = angle_calibration2_deg * (PI / 180.0);
parameter real angle_calibration3_rad = angle_calibration3_deg * (PI / 180.0);

// Precompute sin(steering_angle_rad)
parameter real sin_steering_angle = $sin(steering_angle_rad);

// Compute phase shift, theta, for each element
parameter real theta0 = PI * 0 * sin_steering_angle + angle_calibration0_rad;
parameter real theta1 = PI * 1 * sin_steering_angle + angle_calibration1_rad;
parameter real theta2 = PI * 2 * sin_steering_angle + angle_calibration2_rad;
parameter real theta3 = PI * 3 * sin_steering_angle + angle_calibration3_rad;

// Compute cos(theta) and sin(theta) for each element
parameter real cos_theta0 = $cos(theta0);
parameter real sin_theta0 = $sin(theta0);
parameter real cos_theta1 = $cos(theta1);
parameter real sin_theta1 = $sin(theta1);
parameter real cos_theta2 = $cos(theta2);
parameter real sin_theta2 = $sin(theta2);
parameter real cos_theta3 = $cos(theta3);
parameter real sin_theta3 = $sin(theta3);

// Define scale factor for fixed-point representation
parameter integer SCALE = (1 << (WORD_LENGTH_I_AND_Q - 1)) - 1;

// Convert to fixed-point integers
parameter signed [WORD_LENGTH_I_AND_Q-1:0] Is1 = $rtoi(cos_theta0 * SCALE);
parameter signed [WORD_LENGTH_I_AND_Q-1:0] Qs1 = $rtoi(-sin_theta0 * SCALE);
parameter signed [WORD_LENGTH_I_AND_Q-1:0] Is2 = $rtoi(cos_theta1 * SCALE);
parameter signed [WORD_LENGTH_I_AND_Q-1:0] Qs2 = $rtoi(-sin_theta1 * SCALE);
parameter signed [WORD_LENGTH_I_AND_Q-1:0] Is3 = $rtoi(cos_theta2 * SCALE);
parameter signed [WORD_LENGTH_I_AND_Q-1:0] Qs3 = $rtoi(-sin_theta2 * SCALE);
parameter signed [WORD_LENGTH_I_AND_Q-1:0] Is4 = $rtoi(cos_theta3 * SCALE);
parameter signed [WORD_LENGTH_I_AND_Q-1:0] Qs4 = $rtoi(-sin_theta3 * SCALE);

/////////////////
// Calculation //
/////////////////

// Split AXI stream input into samples //
wire signed [WORD_LENGTH_I_AND_Q-1: 0] Ix1 = s_axis_tdata[1*WORD_LENGTH_I_AND_Q-1 -: WORD_LENGTH_I_AND_Q];
wire signed [WORD_LENGTH_I_AND_Q-1: 0] Qx1 = s_axis_tdata[2*WORD_LENGTH_I_AND_Q-1 -: WORD_LENGTH_I_AND_Q];
wire signed [WORD_LENGTH_I_AND_Q-1: 0] Ix2 = s_axis_tdata[3*WORD_LENGTH_I_AND_Q-1 -: WORD_LENGTH_I_AND_Q];
wire signed [WORD_LENGTH_I_AND_Q-1: 0] Qx2 = s_axis_tdata[4*WORD_LENGTH_I_AND_Q-1 -: WORD_LENGTH_I_AND_Q];
wire signed [WORD_LENGTH_I_AND_Q-1: 0] Ix3 = s_axis_tdata[5*WORD_LENGTH_I_AND_Q-1 -: WORD_LENGTH_I_AND_Q];
wire signed [WORD_LENGTH_I_AND_Q-1: 0] Qx3 = s_axis_tdata[6*WORD_LENGTH_I_AND_Q-1 -: WORD_LENGTH_I_AND_Q];
wire signed [WORD_LENGTH_I_AND_Q-1: 0] Ix4 = s_axis_tdata[7*WORD_LENGTH_I_AND_Q-1 -: WORD_LENGTH_I_AND_Q];
wire signed [WORD_LENGTH_I_AND_Q-1: 0] Qx4 = s_axis_tdata[8*WORD_LENGTH_I_AND_Q-1 -: WORD_LENGTH_I_AND_Q];

// Output from sq_abs_cmul_4ch
wire signed [WORD_LENGTH_POWER_MOMENTARY-1: 0] result_abs_sq_cmul;

sq_abs_cmul_4ch #(.WORD_LENGTH_IN(WORD_LENGTH_I_AND_Q))
sq_abs_cmul_4ch_inst (
	.I_x1(Ix1),
	.Q_x1(Qx1),
	.I_x2(Ix2),
	.Q_x2(Qx2),
	.I_x3(Ix3),
	.Q_x3(Qx3),
	.I_x4(Ix4),
	.Q_x4(Qx4),
	.I_s1(Is1),
	.Q_s1(Qs1),
	.I_s2(Is2),
	.Q_s2(Qs2),
	.I_s3(Is3),
	.Q_s3(Qs3),
	.I_s4(Is4),
	.Q_s4(Qs4),
	.result_abs_sq_cmul(result_abs_sq_cmul)
);

moving_average #(
	.SNAPSHOT_COUNT(MOVING_AVERAGE_SNAPSHOT_COUNT),
	.WORD_LENGTH_IN(WORD_LENGTH_POWER_MOMENTARY),
	.WORD_LENGTH_OUT(WORD_LENGTH_POWER))
moving_average_inst (
	.clk(clk),
	.rst(rst),
	// Input axis
	.s_axis_tdata(result_abs_sq_cmul),
	.s_axis_tvalid(s_axis_tvalid), // valid signal from top of module
	.s_axis_tready(s_axis_tready),
	// Output axis
	.m_axis_tdata(m_axis_tdata),
	.m_axis_tvalid(m_axis_tvalid),
	.m_axis_tready(m_axis_tready)
);

// Debug print values
initial begin
$display("Steering vectors for angle: %f\n\tIs1: %h\n\tQs1: %h\n\tIs2: %h\n\tQs2: %h\n\tIs3: %h\n\tQs3: %h\n\tIs4: %h\n\tQs4: %h\n\t", steering_angle_deg, Is1, Qs1, Is2, Qs2, Is3, Qs3, Is4, Qs4);
end

endmodule

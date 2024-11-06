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
	parameter WORD_LENGTH_OUT = WORD_LENGTH_POWER // should be even number of bytes
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
	input  m_axis_tready, // ignored
	// Steering vectors
	input signed [WORD_LENGTH_I_AND_Q-1:0] Is1,
	input signed [WORD_LENGTH_I_AND_Q-1:0] Qs1,
	input signed [WORD_LENGTH_I_AND_Q-1:0] Is2,
	input signed [WORD_LENGTH_I_AND_Q-1:0] Qs2,
	input signed [WORD_LENGTH_I_AND_Q-1:0] Is3,
	input signed [WORD_LENGTH_I_AND_Q-1:0] Qs3,
	input signed [WORD_LENGTH_I_AND_Q-1:0] Is4,
	input signed [WORD_LENGTH_I_AND_Q-1:0] Qs4
);

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

endmodule

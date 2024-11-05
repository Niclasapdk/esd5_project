`resetall
`timescale 1ns / 1ps
`default_nettype none

module cbf_spectrum_estimator
#(
	parameter MOVING_AVERAGE_SNAPSHOT_COUNT = 8, // should be some 2^x
	parameter WORD_LENGTH_I_AND_Q = 16, // should be even number of bytes
	parameter WORD_LENGTH_IN = 8, // should be even number of bytes
	parameter real PHI_SCAN_STEP = 2,
	parameter real PHI_SCAN_FROM = -50, // inclusive
	parameter real PHI_SCAN_TO = 51, // exclusive
	// Input constants in degrees
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
	input  s_axis_tlast,
	output s_axis_tready
	// Output axis
	// output [WORD_LENGTH_OUT-1 : 0] m_axis_tdata,
	// output m_axis_tvalid,
	// input  m_axis_tready
);

parameter WORD_LENGTH_SAMPLE_AXIS = WORD_LENGTH_I_AND_Q*8; // should be even number of bytes
parameter WORD_LENGTH_POWER = ((WORD_LENGTH_I_AND_Q*2)+8)*2+MOVING_AVERAGE_SNAPSHOT_COUNT;
parameter WORD_LENGTH_POWER_SPECTRUM = WORD_LENGTH_POWER*PHI_SCAN_NUM_STEPS;
parameter PHI_SCAN_NUM_STEPS = (PHI_SCAN_TO-PHI_SCAN_FROM)/PHI_SCAN_STEP;

// Convert input axis to 4-sample wordlength tdata
wire [WORD_LENGTH_SAMPLE_AXIS-1 : 0] input_sample_tdata;
wire input_sample_tvalid;
wire input_sample_tready;
axis_fifo_adapter #(
    .DEPTH(4096),
    .S_DATA_WIDTH(8),
    .M_DATA_WIDTH(WORD_LENGTH_SAMPLE_AXIS),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0),
    .FRAME_FIFO(0))
input_axis_fifo_adapter (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    // AXI output
    .m_axis_tdata(input_sample_tdata),
    .m_axis_tvalid(input_sample_tvalid),
    .m_axis_tready(input_sample_tready),
    .m_axis_tlast()
);

// power spectrum of entire scan angle area
wire [WORD_LENGTH_POWER_SPECTRUM-1 : 0] power_spectrum_tdata;
wire [PHI_SCAN_NUM_STEPS-1 : 0] power_spectrum_tready;
wire [PHI_SCAN_NUM_STEPS-1 : 0] power_spectrum_tvalid;

genvar i;
generate
	for (i=0; i<PHI_SCAN_NUM_STEPS; i=i+1) begin : generator_cbf_power_estimator
		wire [WORD_LENGTH_POWER-1: 0] sliced_power_spectrum_tdata;
		assign power_spectrum_tdata[WORD_LENGTH_POWER*(i+1)-1 -: WORD_LENGTH_POWER] = sliced_power_spectrum_tdata ;
		cbf_power_estimator #(
			.MOVING_AVERAGE_SNAPSHOT_COUNT(MOVING_AVERAGE_SNAPSHOT_COUNT), // should be some 2^x
			.WORD_LENGTH_I_AND_Q(WORD_LENGTH_I_AND_Q), // should be even number of bytes
			.WORD_LENGTH_IN(WORD_LENGTH_SAMPLE_AXIS), // should be even number of bytes
			.WORD_LENGTH_OUT(WORD_LENGTH_POWER),
			.steering_angle_deg(PHI_SCAN_FROM + PHI_SCAN_STEP*i),
			.angle_calibration0_deg(0),
			.angle_calibration1_deg(0),
			.angle_calibration2_deg(0),
			.angle_calibration3_deg(0))
		cbf_power_estimator_inst (
			.clk(clk),
			.rst(rst),
			// Input axis
			.s_axis_tdata(input_sample_tdata),
			.s_axis_tvalid(input_sample_tvalid),
			.s_axis_tready(input_sample_tready),
			// Output axis
			.m_axis_tdata(sliced_power_spectrum_tdata),
			.m_axis_tvalid(power_spectrum_tvalid[i]),
			.m_axis_tready(power_spectrum_tready[i])
		);
	end
endgenerate

endmodule

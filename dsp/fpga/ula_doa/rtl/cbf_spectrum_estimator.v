`resetall
`timescale 1ns / 1ps
`default_nettype none

module cbf_spectrum_estimator
#(
	parameter MOVING_AVERAGE_SNAPSHOT_COUNT = 8, // should be some 2^x
	parameter WORD_LENGTH_I_AND_Q = 16, // should be even number of bytes
	parameter WORD_LENGTH_IN = 8, // should be even number of bytes
	parameter WORD_LENGTH_SAMPLE_AXIS = WORD_LENGTH_I_AND_Q*8, // should be even number of bytes
	parameter WORD_LENGTH_POWER = ((WORD_LENGTH_I_AND_Q*2)+8)*2+MOVING_AVERAGE_SNAPSHOT_COUNT,
	// PHI_SCAN_NUM_STEPS defined in beamscan_header.vh
	parameter WORD_LENGTH_POWER_SPECTRUM = WORD_LENGTH_POWER*PHI_SCAN_NUM_STEPS
)
(
	input clk,
	input rst,
	// Input axis
	input [WORD_LENGTH_IN-1 : 0] s_axis_tdata,
	input  s_axis_tvalid,
	input  s_axis_tlast,
	output s_axis_tready,
	// Output axis
	output [WORD_LENGTH_POWER-1 : 0] m_axis_tdata,
	output m_axis_tvalid,
	output m_axis_tlast,
	input  m_axis_tready,
	// Debug
    output [WORD_LENGTH_POWER_SPECTRUM-1 : 0] power_spectrum_axis_tdata,
    output power_spectrum_axis_tvalid,
    input  power_spectrum_axis_tready
);

// `include "autogenerated/beamscan_header.vh"
`include "../../../rtl/autogenerated/beamscan_header.vh"

// parameter WORD_LENGTH_OUT = WORD_LENGTH_POWER_SPECTRUM;

// Convert input axis to 4-sample wordlength tdata
wire [WORD_LENGTH_SAMPLE_AXIS-1 : 0] input_sample_tdata;
wire input_sample_tvalid;
wire [PHI_SCAN_NUM_STEPS-1: 0] slices_input_sample_tready;
wire input_sample_tready;
assign input_sample_tready = &slices_input_sample_tready;
axis_fifo_adapter #(
    .DEPTH(128),
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
wire [PHI_SCAN_NUM_STEPS-1 : 0] power_spectrum_slices_valid;
wire power_spectrum_tvalid = &power_spectrum_slices_valid;
wire power_spectrum_tready;

assign power_spectrum_axis_tdata = power_spectrum_tdata;
assign power_spectrum_axis_tvalid = power_spectrum_tvalid;

reg signed [WORD_LENGTH_I_AND_Q-1: 0] I_steervecs_1 [0: PHI_SCAN_NUM_STEPS-1];
reg signed [WORD_LENGTH_I_AND_Q-1: 0] I_steervecs_2 [0: PHI_SCAN_NUM_STEPS-1];
reg signed [WORD_LENGTH_I_AND_Q-1: 0] I_steervecs_3 [0: PHI_SCAN_NUM_STEPS-1];
reg signed [WORD_LENGTH_I_AND_Q-1: 0] I_steervecs_4 [0: PHI_SCAN_NUM_STEPS-1];
reg signed [WORD_LENGTH_I_AND_Q-1: 0] Q_steervecs_1 [0: PHI_SCAN_NUM_STEPS-1];
reg signed [WORD_LENGTH_I_AND_Q-1: 0] Q_steervecs_2 [0: PHI_SCAN_NUM_STEPS-1];
reg signed [WORD_LENGTH_I_AND_Q-1: 0] Q_steervecs_3 [0: PHI_SCAN_NUM_STEPS-1];
reg signed [WORD_LENGTH_I_AND_Q-1: 0] Q_steervecs_4 [0: PHI_SCAN_NUM_STEPS-1];

initial begin
	$readmemh("../../../rtl/autogenerated/I_steervecs_1.hex", I_steervecs_1);
	$readmemh("../../../rtl/autogenerated/I_steervecs_2.hex", I_steervecs_2);
	$readmemh("../../../rtl/autogenerated/I_steervecs_3.hex", I_steervecs_3);
	$readmemh("../../../rtl/autogenerated/I_steervecs_4.hex", I_steervecs_4);
	$readmemh("../../../rtl/autogenerated/Q_steervecs_1.hex", Q_steervecs_1);
	$readmemh("../../../rtl/autogenerated/Q_steervecs_2.hex", Q_steervecs_2);
	$readmemh("../../../rtl/autogenerated/Q_steervecs_3.hex", Q_steervecs_3);
	$readmemh("../../../rtl/autogenerated/Q_steervecs_4.hex", Q_steervecs_4);
end

genvar i;
generate
	for (i=0; i<PHI_SCAN_NUM_STEPS; i=i+1) begin : generator_cbf_power_estimator
		wire [WORD_LENGTH_POWER-1: 0] sliced_power_spectrum_tdata;
		assign power_spectrum_tdata[WORD_LENGTH_POWER*(i+1)-1 -: WORD_LENGTH_POWER] = sliced_power_spectrum_tdata;
		wire sliced_power_spectrum_tvalid;
		assign power_spectrum_slices_valid[i] = sliced_power_spectrum_tvalid;
		cbf_power_estimator #(
			.MOVING_AVERAGE_SNAPSHOT_COUNT(MOVING_AVERAGE_SNAPSHOT_COUNT), // should be some 2^x
			.WORD_LENGTH_I_AND_Q(WORD_LENGTH_I_AND_Q), // should be even number of bytes
			.WORD_LENGTH_IN(WORD_LENGTH_SAMPLE_AXIS), // should be even number of bytes
			.WORD_LENGTH_OUT(WORD_LENGTH_POWER))
		cbf_power_estimator_inst (
			.clk(clk),
			.rst(rst),
			// Input axis
			.s_axis_tdata(input_sample_tdata),
			.s_axis_tvalid(input_sample_tvalid),
			.s_axis_tready(slices_input_sample_tready[i]),
			// Output axis
			.m_axis_tdata(sliced_power_spectrum_tdata),
			.m_axis_tvalid(sliced_power_spectrum_tvalid),
			.m_axis_tready(power_spectrum_tready),
			// Steering vectors
			.Is1(I_steervecs_1[i]),
			.Is2(I_steervecs_2[i]),
			.Is3(I_steervecs_3[i]),
			.Is4(I_steervecs_4[i]),
			.Qs1(Q_steervecs_1[i]),
			.Qs2(Q_steervecs_2[i]),
			.Qs3(Q_steervecs_3[i]),
			.Qs4(Q_steervecs_4[i])
		);
	end
endgenerate

axis_fifo_adapter #(
    .DEPTH(4096),
    .S_DATA_WIDTH(WORD_LENGTH_POWER_SPECTRUM),
    .M_DATA_WIDTH(WORD_LENGTH_POWER),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0),
    .FRAME_FIFO(0))
output_axis_fifo_adapter (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(power_spectrum_tdata),
    .s_axis_tvalid(power_spectrum_tvalid),
    .s_axis_tready(power_spectrum_tready),
    .s_axis_tlast(1'b1),
    // AXI output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast)
);

endmodule

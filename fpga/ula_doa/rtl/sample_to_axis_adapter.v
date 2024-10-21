// Language: Verilog-2001

`resetall
`timescale 1 ns / 1 ps
`default_nettype none

/*
 * Converts IQ-samples to AXI stream
 */
module sample_to_axis_adapter  #(
	parameter SAMPLE_WIDTH = 12,
	parameter S_DATA_WIDTH = SAMPLE_WIDTH*2,
	parameter AXI_DATA_WIDTH = 8
)(
	input clk,
	input rst,
	// sample input
	input [SAMPLE_WIDTH-1: 0] I_in,
	input [SAMPLE_WIDTH-1: 0] Q_in,
	input                     input_valid,
	// axis output
	output wire [AXI_DATA_WIDTH-1:0] m_axis_tdata,
    output wire                      m_axis_tvalid,
    input  wire                      m_axis_tready,
    output wire                      m_axis_tlast,
    output wire                      m_axis_tuser
);

wire [S_DATA_WIDTH-1: 0] axis_input_tdata;
assign axis_input_tdata = {I_in, Q_in};

axis_fifo_adapter #(
    // FIFO depth in words
    // Rounded up to nearest power of 2 cycles
    .DEPTH(1024),
    .S_DATA_WIDTH(SAMPLE_WIDTH*2),
    .M_DATA_WIDTH(AXI_DATA_WIDTH)
)
axis_fifo_adapter_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(axis_input_tdata),
    .s_axis_tkeep(),
    .s_axis_tvalid(input_valid),
    .s_axis_tready(),
    .s_axis_tlast(1'b1),
    .s_axis_tid(),
    .s_axis_tdest(),
    .s_axis_tuser(),
    // AXI output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(m_axis_tuser)
);

endmodule

`resetall

/*

Original Copyright (c) 2020 Alex Forencich

The code was modified in this project.

Markus Heinrich Toribio

*/

// Language: Verilog 2001
// Start or End siganl
// OR timeout setting (counter)

`resetall
`timescale 1ns / 1ps
`default_nettype none


// FPGA core logic

module ethernet_connection #
(
    parameter TARGET = "GENERIC"
)
(
    // Clock: 125MHz
    // Synchronous reset
    input  wire       i_clk,
    input  wire       i_clk90,
    input  wire       rst,
    
    // Output raw Ethernet frame data
    output wire       o_eth_rx_valid,
    output wire [7:0] o_eth_rx_data,
    output wire       o_eth_rx_last,
    input  wire       i_eth_rx_ready,  // Flow control signal

    // Ethernet: 1000BASE-T RGMII
    input  wire       phy0_rx_clk,
    input  wire [3:0] phy0_rxd,
    input  wire       phy0_rx_ctl,
    output wire       phy0_tx_clk,
    output wire [3:0] phy0_txd,
    output wire       phy0_tx_ctl,
    output wire       phy0_reset_n,
    input  wire       phy0_int_n
);

// AXI between MAC and Ethernet modules
wire [7:0] rx_axis_tdata;
wire       rx_axis_tvalid;
wire       rx_axis_tready;
wire       rx_axis_tlast;
wire       rx_axis_tuser;

wire [7:0] tx_axis_tdata;
wire       tx_axis_tvalid;
wire       tx_axis_tready;
wire       tx_axis_tlast;
wire       tx_axis_tuser;

// Ethernet frame between Ethernet module and FIFO?
wire rx_eth_hdr_ready;
wire rx_eth_hdr_valid;
wire [47:0] rx_eth_dest_mac;
wire [47:0] rx_eth_src_mac;
wire [15:0] rx_eth_type;
wire [7:0] rx_eth_payload_axis_tdata;
wire rx_eth_payload_axis_tvalid;
wire rx_eth_payload_axis_tready;
wire rx_eth_payload_axis_tlast;
wire rx_eth_payload_axis_tuser;

wire tx_eth_hdr_ready;
wire tx_eth_hdr_valid;
wire [47:0] tx_eth_dest_mac;
wire [47:0] tx_eth_src_mac;
wire [15:0] tx_eth_type;
wire [7:0] tx_eth_payload_axis_tdata;
wire tx_eth_payload_axis_tvalid;
wire tx_eth_payload_axis_tready;
wire tx_eth_payload_axis_tlast;
wire tx_eth_payload_axis_tuser;

// Assign FIFO output to module outputs
// assign o_eth_rx_data  = rx_eth_payload_axis_tdata;
// assign o_eth_rx_valid = rx_eth_payload_axis_tvalid;
// assign o_eth_rx_last  = rx_eth_payload_axis_tlast;
// assign o_eth_rx_data  = rx_axis_tdata;
// assign o_eth_rx_valid = rx_axis_tvalid;
// assign o_eth_rx_last  = rx_axis_tlast;
// assign o_eth_rx_data  = rx_fifo_axis_tdata;
// assign o_eth_rx_data  = rx_eth_payload_axis_tdata;
assign o_eth_rx_valid = tx_axis_tvalid;
assign o_eth_rx_last  = tx_axis_tlast;
assign o_eth_rx_data  = tx_axis_tdata;

// Connect the ready signal for flow control
// assign rx_eth_payload_axis_tready = i_eth_rx_ready;
// assign rx_fifo_axis_tready = i_eth_rx_ready;

// Loopback
assign tx_eth_hdr_ready = rx_eth_hdr_ready;
assign tx_eth_hdr_valid = rx_eth_hdr_valid;
// assign tx_eth_dest_mac = rx_eth_src_mac;
assign tx_eth_dest_mac = 48'hffffffffffff;
assign tx_eth_src_mac = 48'haaaaaaaaaaaa;
assign tx_eth_type = rx_eth_type;
assign tx_eth_payload_axis_tdata  = rx_eth_payload_axis_tdata;
assign tx_eth_payload_axis_tvalid = rx_eth_payload_axis_tvalid;
assign tx_eth_payload_axis_tready = rx_eth_payload_axis_tready;
assign tx_eth_payload_axis_tlast  = rx_eth_payload_axis_tlast;
assign tx_eth_payload_axis_tuser  = rx_eth_payload_axis_tuser;

assign phy0_reset_n = ~rst;

// Instantiate the MAC with FIFO interfaces
eth_mac_1g_rgmii_fifo #(
    .TARGET(TARGET),
    .USE_CLK90("TRUE"),
    .ENABLE_PADDING(1),
    .MIN_FRAME_LENGTH(8),
    .TX_FIFO_DEPTH(4096),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(4096),
    .RX_FRAME_FIFO(1)
)
eth_mac_inst (
	// Clocks and reset
    .gtx_clk(i_clk),
    .gtx_clk90(i_clk90),
    .gtx_rst(rst),
    .logic_clk(i_clk),
    .logic_rst(rst),
	// TX input AXI stream
    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
	// RX output AXI stream
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),
	// RGMII interface to PHY
    .rgmii_rx_clk(phy0_rx_clk),
    .rgmii_rxd(phy0_rxd),
    .rgmii_rx_ctl(phy0_rx_ctl),
    .rgmii_tx_clk(phy0_tx_clk),
    .rgmii_txd(phy0_txd),
    .rgmii_tx_ctl(phy0_tx_ctl),
	// Status signals
    .tx_fifo_overflow(),
    .tx_fifo_bad_frame(),
    .tx_fifo_good_frame(),
    .rx_error_bad_frame(),
    .rx_error_bad_fcs(),
    .rx_fifo_overflow(),
    .rx_fifo_bad_frame(),
    .rx_fifo_good_frame(),
    .speed(),
	// Config
    .cfg_ifg(8'd12),
    .cfg_tx_enable(1'b1),
    .cfg_rx_enable(1'b1)
);

eth_axis_rx eth_axis_rx_inst (
	.clk(i_clk),
	.rst(rst),
	// AXI input
	.s_axis_tdata(rx_axis_tdata),
	.s_axis_tvalid(rx_axis_tvalid),
	.s_axis_tready(rx_axis_tready),
	.s_axis_tlast(rx_axis_tlast),
	.s_axis_tuser(rx_axis_tuser),
	// Ethernet frame output
    .m_eth_hdr_valid(rx_eth_hdr_valid),
    .m_eth_hdr_ready(rx_eth_hdr_ready),
    .m_eth_dest_mac(rx_eth_dest_mac),
    .m_eth_src_mac(rx_eth_src_mac),
    .m_eth_type(rx_eth_type),
    .m_eth_payload_axis_tdata(rx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tvalid(rx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(rx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(rx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(rx_eth_payload_axis_tuser),
    // Status signals
    .busy(),
    .error_header_early_termination()
);

eth_axis_tx eth_axis_tx_inst (
	.clk(i_clk),
	.rst(rst),
	// Ethernet frame input
    .s_eth_hdr_valid(tx_eth_hdr_valid),
    .s_eth_hdr_ready(tx_eth_hdr_ready),
    .s_eth_dest_mac(tx_eth_dest_mac),
    .s_eth_src_mac(tx_eth_src_mac),
    .s_eth_type(tx_eth_type),
    .s_eth_payload_axis_tdata(tx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tvalid(tx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(tx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(tx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(tx_eth_payload_axis_tuser),
	// AXI output
	.m_axis_tdata(tx_axis_tdata),
	.m_axis_tvalid(tx_axis_tvalid),
	.m_axis_tready(tx_axis_tready),
	.m_axis_tlast(tx_axis_tlast),
	.m_axis_tuser(tx_axis_tuser),
    // Status signals
    .busy(),
    .error_header_early_termination()
);

endmodule

`resetall

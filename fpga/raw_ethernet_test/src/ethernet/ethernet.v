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

// Signals for FIFO output
wire [7:0] rx_fifo_axis_tdata;
wire       rx_fifo_axis_tvalid;
wire       rx_fifo_axis_tready;
wire       rx_fifo_axis_tlast;
wire       rx_fifo_axis_tuser;

// Assign FIFO output to module outputs
// assign o_eth_rx_data  = rx_eth_payload_axis_tdata;
// assign o_eth_rx_valid = rx_eth_payload_axis_tvalid;
// assign o_eth_rx_last  = rx_eth_payload_axis_tlast;
// assign o_eth_rx_data  = rx_axis_tdata;
// assign o_eth_rx_valid = rx_axis_tvalid;
// assign o_eth_rx_last  = rx_axis_tlast;
// assign o_eth_rx_data  = rx_fifo_axis_tdata;
assign o_eth_rx_data  = rx_eth_payload_axis_tdata;
assign o_eth_rx_valid = rx_eth_payload_axis_tvalid;
assign o_eth_rx_last  = rx_eth_payload_axis_tuser;

// Connect the ready signal for flow control
// assign rx_eth_payload_axis_tready = i_eth_rx_ready;
// assign rx_fifo_axis_tready = i_eth_rx_ready;

// WTF
assign tx_axis_tdata = rx_axis_tdata;
assign tx_axis_tvalid = rx_axis_tvalid;
assign rx_axis_tready = tx_axis_tready;
assign tx_axis_tlast = rx_axis_tlast;
assign tx_axis_tuser = rx_axis_tuser;


assign phy0_reset_n = ~rst;

// Instantiate the MAC with FIFO interfaces
eth_mac_1g_rgmii_fifo #(
    .TARGET(TARGET),
    .USE_CLK90("FALSE"),
    .ENABLE_PADDING(1),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_DEPTH(4096),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(4096),
    .RX_FRAME_FIFO(1)
)
eth_mac_inst (
    .gtx_clk(i_clk),
    .gtx_clk90(i_clk90),
    .gtx_rst(rst),
    .logic_clk(i_clk),
    .logic_rst(rst),

    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),

    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),

    .rgmii_rx_clk(phy0_rx_clk),
    .rgmii_rxd(phy0_rxd),
    .rgmii_rx_ctl(phy0_rx_ctl),
    .rgmii_tx_clk(phy0_tx_clk),
    .rgmii_txd(phy0_txd),
    .rgmii_tx_ctl(phy0_tx_ctl),
    
    .tx_fifo_overflow(),
    .tx_fifo_bad_frame(),
    .tx_fifo_good_frame(),
    .rx_error_bad_frame(),
    .rx_error_bad_fcs(),
    .rx_fifo_overflow(),
    .rx_fifo_bad_frame(),
    .rx_fifo_good_frame(),
    .speed(),
	
    .cfg_ifg(8'd12),
    .cfg_tx_enable(1'b1),
    .cfg_rx_enable(1'b1)
);

// eth_axis_rx eth_axis_rx_inst (
// 	.clk(i_clk),
// 	.rst(rst),
// 	// AXI input
// 	.s_axis_tdata(rx_axis_tdata),
// 	.s_axis_tvalid(rx_axis_tvalid),
// 	.s_axis_tready(rx_axis_tready),
// 	.s_axis_tlast(rx_axis_tlast),
// 	.s_axis_tuser(rx_axis_tuser),
// 	// Ethernet frame output
//     .m_eth_hdr_valid(rx_eth_hdr_valid),
//     .m_eth_hdr_ready(rx_eth_hdr_ready),
//     .m_eth_dest_mac(rx_eth_dest_mac),
//     .m_eth_src_mac(rx_eth_src_mac),
//     .m_eth_type(rx_eth_type),
//     .m_eth_payload_axis_tdata(rx_eth_payload_axis_tdata),
//     .m_eth_payload_axis_tvalid(rx_eth_payload_axis_tvalid),
//     .m_eth_payload_axis_tready(rx_eth_payload_axis_tready),
//     .m_eth_payload_axis_tlast(rx_eth_payload_axis_tlast),
//     .m_eth_payload_axis_tuser(rx_eth_payload_axis_tuser),
//     // Status signals
//     .busy(),
//     .error_header_early_termination()
// );
//
// // Instantiate the AXI Stream FIFO for Ethernet frames
// axis_fifo #(
//     .DEPTH(8192),
//     .DATA_WIDTH(8),
//     .KEEP_ENABLE(0),
//     .ID_ENABLE(0),
//     .DEST_ENABLE(0),
//     .USER_ENABLE(1),
//     .USER_WIDTH(1),
//     .FRAME_FIFO(0)  // Use frame mode to handle entire Ethernet frames
// )
// eth_frame_fifo (
//     .clk(i_clk),
//     .rst(rst),
//
//     // // AXI input from MAC RX interface
//     // .s_axis_tdata(rx_eth_payload_axis_tdata),
//     // .s_axis_tkeep(0),
//     // .s_axis_tvalid(rx_eth_payload_axis_tvalid),
//     // .s_axis_tready(rx_eth_payload_axis_tready),
//     // .s_axis_tlast(rx_eth_payload_axis_tlast),
//     // .s_axis_tid(0),
//     // .s_axis_tdest(0),
//     // .s_axis_tuser(rx_eth_payload_axis_tuser),
//
//     // AXI output to module outputs
//     .m_axis_tdata(rx_fifo_axis_tdata),
//     .m_axis_tkeep(),
//     .m_axis_tvalid(rx_fifo_axis_tvalid),
//     .m_axis_tready(rx_fifo_axis_tready),
//     .m_axis_tlast(rx_fifo_axis_tlast),
//     .m_axis_tid(),
//     .m_axis_tdest(),
//     .m_axis_tuser(rx_fifo_axis_tuser),
//
//     // Status signals
//     .status_overflow(),
//     .status_bad_frame(),
//     .status_good_frame()
// );

endmodule

`resetall

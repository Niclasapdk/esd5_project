// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FPGA core logic
 */
module fpga_core #
(
    parameter TARGET = "GENERIC"
)
(
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    input  wire       clk,
    input  wire       clk90,
    input  wire       rst,

    /*
     * GPIO
     */
    input  wire [3:0]  btn,
    input  wire [17:0] sw,
    output wire [8:0]  ledg,
    output wire [17:0] ledr,
    output wire [6:0]  hex0,
    output wire [6:0]  hex1,
    output wire [6:0]  hex2,
    output wire [6:0]  hex3,
    output wire [6:0]  hex4,
    output wire [6:0]  hex5,
    output wire [6:0]  hex6,
    output wire [6:0]  hex7,
    output wire [35:0] gpio,

    /*
     * Ethernet: 1000BASE-T RGMII
     */
    input  wire       phy0_rx_clk,
    input  wire [3:0] phy0_rxd,
    input  wire       phy0_rx_ctl,
    output wire       phy0_tx_clk,
    output wire [3:0] phy0_txd,
    output wire       phy0_tx_ctl,
    output wire       phy0_reset_n,
    input  wire       phy0_int_n,

    input  wire       phy1_rx_clk,
    input  wire [3:0] phy1_rxd,
    input  wire       phy1_rx_ctl,
    output wire       phy1_tx_clk,
    output wire [3:0] phy1_txd,
    output wire       phy1_tx_ctl,
    output wire       phy1_reset_n,
    input  wire       phy1_int_n
);

// Configuration
wire [47:0] local_mac      = 48'h02_00_00_00_00_00;
wire [31:0] local_ip       = {8'd192, 8'd168, 8'd10,   8'd128};
wire [31:0] gateway_ip     = {8'd192, 8'd168, 8'd10,   8'd1};
wire [31:0] subnet_mask    = {8'd255, 8'd255, 8'd255, 8'd0};
wire [15:0] rx_dest_port   = 16'd1234;
wire [15:0] tx_dest_port   = 16'd9000;
wire [15:0] tx_source_port = 16'd1235;
wire [31:0] tx_dest_ip     = {8'd192, 8'd168, 8'd10,   8'd10};

// place data onto 7 segment displays
reg [31:0] seven_segment_reg = 0;
reg [31:0] rx_data_reg = 0;

always @(posedge clk) begin
    if (tx_data_axis_tvalid) begin
        rx_data_reg[7:0] <= rx_data_axis_tdata;
        rx_data_reg[15:8] <= rx_data_reg[7:0];
        rx_data_reg[23:16] <= rx_data_reg[15:8];
        rx_data_reg[31:24] <= rx_data_reg[23:16];
    end

    if (rst) begin
        rx_data_reg <= 0;
    end

	if (sw[0]) begin
		seven_segment_reg <= rx_data_reg;
	end else begin
		seven_segment_reg <= tx_dest_ip;
	end
end

hex_display #(
    .INVERT(1)
)
hex_display_0 (
    .in(seven_segment_reg[3:0]),
    .enable(1),
    .out(hex0)
);

hex_display #(
    .INVERT(1)
)
hex_display_1 (
    .in(seven_segment_reg[7:4]),
    .enable(1),
    .out(hex1)
);

hex_display #(
    .INVERT(1)
)
hex_display_2 (
    .in(seven_segment_reg[11:8]),
    .enable(1),
    .out(hex2)
);

hex_display #(
    .INVERT(1)
)
hex_display_3 (
    .in(seven_segment_reg[15:12]),
    .enable(1),
    .out(hex3)
);

hex_display #(
    .INVERT(1)
)
hex_display_4 (
    .in(seven_segment_reg[19:16]),
    .enable(1),
    .out(hex4)
);

hex_display #(
    .INVERT(1)
)
hex_display_5 (
    .in(seven_segment_reg[23:20]),
    .enable(1),
    .out(hex5)
);

hex_display #(
    .INVERT(1)
)
hex_display_6 (
    .in(seven_segment_reg[27:24]),
    .enable(1),
    .out(hex6)
);

hex_display #(
    .INVERT(1)
)
hex_display_7 (
    .in(seven_segment_reg[31:28]),
    .enable(1),
    .out(hex7)
);

assign ledr = sw;
assign gpio = 0;

// TX data
wire [7:0] tx_data_axis_tdata;
wire       tx_data_axis_tvalid;
wire       tx_data_axis_tready;
wire       tx_data_axis_tlast;
wire       tx_data_axis_tuser;
// RX data
wire [7:0] rx_data_axis_tdata;
wire       rx_data_axis_tvalid;
wire       rx_data_axis_tready;
wire       rx_data_axis_tlast;
wire       rx_data_axis_tuser;

// loopback
// assign rx_data_axis_tdata = tx_data_axis_tdata;
// assign rx_data_axis_tvalid = tx_data_axis_tvalid;
// assign tx_data_axis_tready = rx_data_axis_tready;
// assign rx_data_axis_tlast = tx_data_axis_tlast;
// assign rx_data_axis_tuser = tx_data_axis_tuser;

// Spectrum estimator
cbf_spectrum_estimator
#(
	.MOVING_AVERAGE_SNAPSHOT_COUNT(8), // should be some 2^x
	.WORD_LENGTH_I_AND_Q(16), // should be even number of bytes
	.WORD_LENGTH_IN(8), // should be even number of bytes
	// Degrees
	.PHI_SCAN_STEP(2),
	.PHI_SCAN_FROM(-50), // inclusive
	.PHI_SCAN_TO(51), // exclusive
	.angle_calibration0_deg(0),
	.angle_calibration1_deg(0),
	.angle_calibration2_deg(0),
	.angle_calibration3_deg(0))
cbf_spectrum_estimator_inst (
	.clk(clk),
	.rst(rst),
	// Input axis
	.s_axis_tdata(rx_data_axis_tdata),
	.s_axis_tvalid(rx_data_axis_tvalid),
	.s_axis_tlast(rx_data_axis_tlast),
	.s_axis_tready(rx_data_axis_tready),
	// Output axis
	.m_axis_tdata(tx_data_axis_tdata),
	.m_axis_tvalid(tx_data_axis_tvalid),
	.m_axis_tlast(tx_data_axis_tlast),
	.m_axis_tready(tx_data_axis_tready)
);

udp_connection #(
	.TARGET(TARGET),
	.TX_DATA_WIDTH(88) // TODO fix hardcoded length
)
udp_connection_inst
(
    .clk(clk),
    .clk90(clk90),
    .rst(rst),

    // Ethernet: 1000BASE-T RGMII
    .phy0_rx_clk(phy0_rx_clk),
    .phy0_rxd(phy0_rxd),
    .phy0_rx_ctl(phy0_rx_ctl),
    .phy0_tx_clk(phy0_tx_clk),
    .phy0_txd(phy0_txd),
    .phy0_tx_ctl(phy0_tx_ctl),
    .phy0_reset_n(phy0_reset_n),
    .phy0_int_n(phy0_int_n),
    .phy1_rx_clk(phy1_rx_clk),
    .phy1_rxd(phy1_rxd),
    .phy1_rx_ctl(phy1_rx_ctl),
    .phy1_tx_clk(phy1_tx_clk),
    .phy1_txd(phy1_txd),
    .phy1_tx_ctl(phy1_tx_ctl),
    .phy1_reset_n(phy1_reset_n),
    .phy1_int_n(phy1_int_n),

	// TX data
	.s_tx_data_axis_tdata(tx_data_axis_tdata),
	.s_tx_data_axis_tvalid(tx_data_axis_tvalid),
	.s_tx_data_axis_tready(tx_data_axis_tready),
	.s_tx_data_axis_tlast(tx_data_axis_tlast),
	.s_tx_data_axis_tuser(tx_data_axis_tuser),
	// RX data
	.m_rx_data_axis_tdata(rx_data_axis_tdata),
	.m_rx_data_axis_tvalid(rx_data_axis_tvalid),
	.m_rx_data_axis_tready(rx_data_axis_tready),
	.m_rx_data_axis_tlast(rx_data_axis_tlast),
	.m_rx_data_axis_tuser(rx_data_axis_tuser),

	// Configuration
	.local_mac(local_mac),
	.local_ip(local_ip),
	.gateway_ip(gateway_ip),
	.subnet_mask(subnet_mask),
	.rx_dest_port(rx_dest_port),
	.tx_dest_port(tx_dest_port),
	.tx_source_port(tx_source_port),
	.tx_dest_ip(tx_dest_ip)
);

endmodule

`resetall

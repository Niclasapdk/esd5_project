module raw_ethernet_test (
	// Clock
	input         CLOCK_50,

	// Reset KEY
	input  [0: 0] KEY,

	// Ethernet 0
	output        NET0_GTX_CLK,
	output        NET0_RESET_N,
	input         NET0_RX_CLK,
	input  [3: 0] NET0_RX_DATA,
	input         NET0_RX_DV,
	input         NET0_RX_ER,
	output [3: 0] NET0_TX_DATA,
	output        NET0_TX_EN,
	input         NET0_INT_N,

	// Ethernet 1
	output        NET1_GTX_CLK,
	output        NET1_RESET_N,
	input         NET1_RX_CLK,
	input  [3: 0] NET1_RX_DATA,
	input         NET1_RX_DV,
	input         NET1_RX_ER,
	output [3: 0] NET1_TX_DATA,
	output        NET1_TX_EN,
	input         NET1_INT_N,

	// LEDs
	output        O_VALID,
	output        O_LAST,
	output [7: 0] O_DATA,
	output        O_RESET,
	output        O_DEBOUNCE,

	// Button
	input         I_READY
);

wire core_reset_n;
wire core_reset;
assign core_reset = ~core_reset_n;

wire ethernet_clk;
wire ethernet_clk90;
wire eth_rx_ready;
assign O_DEBOUNCE = NET0_RX_ER;
assign O_RESET = ethernet_clk;
// assign O_DATA[6] = NET0_RX_CLK;
// assign O_DATA[5] = NET0_RX_DV;
// assign O_DATA[3: 0] = NET0_RX_DATA;
// assign NET0_TX_EN = 1;

my_pll pll_inst (
	.areset(~KEY[0]),
	.inclk0(CLOCK_50),
	.c0(sys_clk),
	.c1(ethernet_clk),
	.c2(ethernet_clk90),
	.locked(core_reset_n)
);

assign eth_rx_ready = ~I_READY;

ethernet_connection #(.TARGET("ALTERA"))
ethernet_connection_inst (
    // Clock: 125MHz
    // Synchronous reset
    .i_clk(ethernet_clk),
    .i_clk90(ethernet_clk90),
    .rst(core_reset),
    
    // Output raw Ethernet frame data
    .o_eth_rx_valid(O_VALID),
    .o_eth_rx_data(O_DATA),
    .o_eth_rx_last(O_LAST),
    .i_eth_rx_ready(eth_rx_ready),  // Flow control signal

    // Ethernet: 1000BASE-T RGMII
    .phy_rx_clk(NET0_RX_CLK),
    .phy_rxd(NET0_RX_DATA),
    .phy_rx_ctl(NET0_RX_DV),
    .phy_tx_clk(NET0_GTX_CLK),
    .phy_txd(NET0_TX_DATA),
    .phy_tx_ctl(NET0_TX_EN),
    .phy_reset_n(NET0_RESET_N),
    .phy_int_n(NET0_INT_N)
);

endmodule

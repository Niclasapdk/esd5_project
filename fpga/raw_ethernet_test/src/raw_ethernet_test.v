module raw_ethernet_test (
	// Clock
	input         CLOCK_50,

	// Reset KEY
	input  [0: 0] KEY,

	// Ethernet 0
	output        NET0_RESET_N,
	input         NET0_RX_CLK,
	input  [3: 0] NET0_RX_DATA,
	input         NET0_RX_DV,
	output [3: 0] NET0_TX_DATA,
	output        NET0_TX_EN,

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

wire ethernet_clk;
wire ethernet_clk90;
wire eth_rx_ready;

my_pll pll_inst (
	.areset(~KEY[0]),
	.inclk0(CLOCK_50),
	.c0(sys_clk),
	.c1(ethernet_clk),
	.c2(ethernet_clk90),
	.locked(core_reset_n)
);

debounce debounce_ready_inst(
	.pb_1(I_READY),
	.clk(sys_clk),
	.pb_out(eth_rx_ready)
);

ethernet_connection #(.TARGET("ALTERA"))
ethernet_connection_inst (
    // Clock: 125MHz
    // Synchronous reset
    .i_clk(ethernet_clk),
    .i_clk90(ethernet_clk90),
    .rst(core_reset_n),
    
    // Output raw Ethernet frame data
    .o_eth_rx_valid(O_VALID),
    .o_eth_rx_data(O_DATA),
    .o_eth_rx_last(O_LAST),
    .i_eth_rx_ready(eth_rx_ready),  // Flow control signal

    // Ethernet: 1000BASE-T RGMII
    .phy0_rx_clk(NET0_RX_CLK),
    .phy0_rxd(NET0_RX_DATA),
    .phy0_rx_ctl(NET0_RX_DV),
    .phy0_tx_clk(),
    .phy0_txd(),
    .phy0_tx_ctl(),
    .phy0_reset_n(NET0_RESET_N),
    .phy0_int_n()
);

endmodule

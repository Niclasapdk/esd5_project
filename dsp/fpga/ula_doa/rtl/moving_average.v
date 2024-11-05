`resetall
`timescale 1ns / 1ps
`default_nettype none

module moving_average
#(
	parameter SNAPSHOT_COUNT = 4, // should be some 2^x
	parameter SNAPSHOT_EXPONENT = $clog2(SNAPSHOT_COUNT),
	parameter MA_ARRAY_LENGTH = SNAPSHOT_COUNT-1,
	parameter WORD_LENGTH_IN = 16, // should be even number of bytes
	parameter WORD_LENGTH_SUM = WORD_LENGTH_IN+SNAPSHOT_COUNT,
	parameter WORD_LENGTH_RESULT = WORD_LENGTH_SUM,
	parameter WORD_LENGTH_OUT = WORD_LENGTH_RESULT, // should be even number of bytes
	parameter INTERNAL_AR_SIZE = MA_ARRAY_LENGTH*WORD_LENGTH_IN
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
	input  m_axis_tready
);

// registers
reg [INTERNAL_AR_SIZE-1: 0] internal_ma_array = 0;
reg [WORD_LENGTH_SUM-1: 0]  ma_sum = 0;
reg [WORD_LENGTH_IN-1: 0]   ma_last = 0;
reg signed[WORD_LENGTH_RESULT-1: 0] ma_result = 0;
reg startup_lag_done = 0;
reg in_valid_prev;

reg output_valid = 0;

assign s_axis_tready = 1'b1;
assign m_axis_tvalid = output_valid;

always @(posedge clk) begin
	in_valid_prev <= s_axis_tvalid;
	if (rst) begin
		internal_ma_array <= 0;
		ma_sum <= 0;
		ma_last <= 0;
		ma_result <= 0;
		startup_lag_done <= 1'b0;
	end else begin
		if (s_axis_tvalid) begin
			internal_ma_array[WORD_LENGTH_IN-1 : 0] <= s_axis_tdata;
			ma_sum <= (ma_sum + s_axis_tdata - ma_last);
			ma_last <= internal_ma_array[INTERNAL_AR_SIZE-1 -: WORD_LENGTH_IN];
			internal_ma_array[INTERNAL_AR_SIZE-1 : WORD_LENGTH_IN] <= 
				internal_ma_array[INTERNAL_AR_SIZE-1-WORD_LENGTH_IN : 0];//shift

			// output valid
			if (!startup_lag_done) begin
				startup_lag_done <= 1'b1;
			end
			else begin
				output_valid <= 1'b1;
			end
		end
		if (!s_axis_tvalid && output_valid && m_axis_tready) begin
			output_valid <= 1'b0;
		end
		ma_result <= ma_sum>>SNAPSHOT_EXPONENT;
	end
end
assign m_axis_tdata = ma_result[WORD_LENGTH_RESULT-1 -: WORD_LENGTH_OUT];

endmodule

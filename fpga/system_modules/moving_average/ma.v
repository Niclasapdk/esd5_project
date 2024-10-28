
module ma
#(
    parameter MA_SNAPSHOT_COUNT = 4,
    parameter MA_ARRAY_LENGTH = MA_SNAPSHOT_COUNT-1,
    parameter REAL_SIZE = 64,
    parameter TEMP_MA_AR_SIZE = MA_ARRAY_LENGTH*REAL_SIZE
)
(   
    //inout of commul
    input rst, en, clk,
	input real ma_input, // input of the sample real 
	output wire real ma_out 			//output real imag  
);

//######################################
//registers
//######################################
reg [TEMP_MA_AR_SIZE-1:0] temp_ma_ar = 0;
reg real ma_sum = 0, ma_last = 0;

//######################################
//program
//######################################
always @(posedge clk, posedge rst) begin
    if (rst) begin
        temp_ma_ar = 0;
    end else if (en) begin
        temp_ma_ar[TEMP_MA_AR_SIZE-1 : REAL_SIZE] <= temp_ma_ar[TEMP_MA_AR_SIZE-1-REAL_SIZE:0];//shift
        temp_ma_ar[REAL_SIZE-1: 0] <= ma_input;
        ma_last <= temp_ma_ar[TEMP_MA_AR_SIZE-1 -: REAL_SIZE];
        ma_sum <= (ma_sum + ma_input - ma_last);
    end
end

assign ma_out = ma_sum/MA_SNAPSHOT_COUNT;


endmodule
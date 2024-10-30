
module ma
#(
    parameter MA_SNAPSHOT_COUNT = 4,
    parameter MA_ARRAY_LENGTH = MA_SNAPSHOT_COUNT-1,
    parameter WORD_LENGTH = 16,
    parameter WORD_LENGTH_IN_FROM_CMUL = (WORD_LENGTH*2+3)*2+1, // WORD LENGTH FROM THE CMUL MODULE
    parameter TEMP_MA_AR_SIZE = MA_ARRAY_LENGTH*WORD_LENGTH_IN_FROM_CMUL
)
(   
    //inout of commul
    input rst, en, clk,
	input [WORD_LENGTH_IN_FROM_CMUL-1 : 0] ma_input, // input of the sample real 
	output wire [WORD_LENGTH_IN_FROM_CMUL-1 : 0] ma_out 			//output real imag  
);

//######################################
//registers
//######################################
reg [TEMP_MA_AR_SIZE-1:0] temp_ma_ar = 0;
reg [WORD_LENGTH_IN_FROM_CMUL-1 : 0] ma_sum = 0, ma_last = 0;


//######################################
//program
//######################################
always @(posedge clk, posedge rst) begin
    if (rst) begin
        temp_ma_ar = 0;
    end else if (en) begin
        temp_ma_ar[TEMP_MA_AR_SIZE-1 : WORD_LENGTH_IN_FROM_CMUL] <= 
        temp_ma_ar[TEMP_MA_AR_SIZE-1-WORD_LENGTH_IN_FROM_CMUL : 0];//shift
        
        temp_ma_ar[WORD_LENGTH_IN_FROM_CMUL-1 : 0] <= ma_input;
        ma_last <= temp_ma_ar[TEMP_MA_AR_SIZE-1 -: WORD_LENGTH_IN_FROM_CMUL];
        ma_sum <= (ma_sum + ma_input - ma_last);
    end
end

assign ma_out = ma_sum/MA_SNAPSHOT_COUNT;


endmodule
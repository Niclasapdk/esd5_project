
module ma
#(
        parameter MA_ARRAY_LENGTH = 3,
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
//state machine
//######################################
reg [1:0] state = 0; 
localparam[1:0] st_in = 2'b00,
                st_update = 2'b01,
                st_shift = 2'b10;


//######################################
//registers
//######################################
reg [TEMP_MA_AR_SIZE-1:0] temp_ma_ar = 0;
reg real ma_sum, ma_last, ma_first, temp_sum_test;

//######################################
//program
//######################################
always @(posedge clk, posedge rst) begin
    if (rst) begin
        temp_ma_ar = 0;
        state = st_in;
    end else if (en) begin
        case (state)
            st_in:begin
                temp_ma_ar[REAL_SIZE-1-:REAL_SIZE] <= $realtobits(ma_input);
                state <= st_update;
                end

            st_update:begin
                ma_first <= $bitstoreal(temp_ma_ar[REAL_SIZE-1-:REAL_SIZE]);
                ma_last <= $bitstoreal(temp_ma_ar[TEMP_MA_AR_SIZE-1-:REAL_SIZE]);
                state <= st_shift;
            end

            st_shift:begin
                temp_ma_ar <= temp_ma_ar << REAL_SIZE;
                ma_sum <= (ma_sum + ma_first - ma_last)/MA_ARRAY_LENGTH;
                temp_sum_test <= ma_sum + ma_first - ma_last;
                state <= st_in;
            end
        endcase
    end
end



//always @(posedge clk, posedge rst) begin
 //   if (rst) begin
  //      temp_ma_ar = 0;
  //  end else if (en) begin
  //      temp_ma_ar[REAL_SIZE-1-:REAL_SIZE] <= $realtobits(ma_input);
  //      ma_sum <= (ma_sum + ma_first - ma_last)/MA_ARRAY_LENGTH;
  //      temp_sum_test <= ma_sum + ma_first - ma_last;
 //   end
//end

//always @(negedge clk) begin
    // if (en) begin
  //      temp_ma_ar <= temp_ma_ar << REAL_SIZE;
   //     ma_first <= $bitstoreal(temp_ma_ar[REAL_SIZE-1-:REAL_SIZE]);
   //     ma_last <= $bitstoreal(temp_ma_ar[TEMP_MA_AR_SIZE-1-:REAL_SIZE]);
        
  //  end
//end


endmodule
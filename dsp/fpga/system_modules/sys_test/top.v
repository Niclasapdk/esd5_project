module top
#(
		parameter WORD_LENGTH = 16,
        parameter WORD_LENGTH_OUT = (WORD_LENGTH*2+3)*2+1 // word length from cmul
)
(   
        //input abs_sq_cmul module
		input signed[WORD_LENGTH-1:0] I_x1, I_x2, I_x3, I_x4, // input of the sample real 
		input signed[WORD_LENGTH-1:0] Q_x1, Q_x2, Q_x3, Q_x4, //input smaple imag 
		input signed[WORD_LENGTH-1:0] I_s1, I_s2, I_s3, I_s4, //real steering vedtor
		input signed[WORD_LENGTH-1:0] Q_s1, Q_s2, Q_s3, Q_s4,	//imag steeing vector
		output wire signed [WORD_LENGTH_OUT-1:0] result_abs_sq_cmul,			//output real imag 

        //input ma module
        input rst, en, clk,
	    input [WORD_LENGTH_OUT-1 : 0] ma_input, // input of the sample real 
	    output wire [WORD_LENGTH_OUT-1 : 0] ma_out 			//output real imag   
);

abs_sq_cmul #(
    .WORD_LENGTH(WORD_LENGTH),
    .WORD_LENGTH_OUT(WORD_LENGTH_OUT)
)abs_sq_cmul (
    .I_x1(I_x1), .I_x2(I_x2), .I_x3(I_x3), .I_x4(I_x4),
    .Q_x1(Q_x1), .Q_x2(Q_x2), .Q_x3(Q_x3), .Q_x4(Q_x4),
    .I_s1(I_s1), .I_s2(I_s2), .I_s3(I_s3), .I_s4(I_s4),
    .Q_s1(Q_s1), .Q_s2(Q_s2), .Q_s3(Q_s3), .Q_s4(Q_s4),
    .result_abs_sq_cmul(result_abs_sq_cmul)
);

ma #(
    .WORD_LENGTH_IN_FROM_CMUL(WORD_LENGTH_OUT)
) ma (
    .rst(rst),
    .en(en),
    .clk(clk),
    .ma_input(ma_input),
    .ma_out(ma_out)
);

//##################################
//program
//##################################
assign ma_input = result_abs_sq_cmul;

endmodule

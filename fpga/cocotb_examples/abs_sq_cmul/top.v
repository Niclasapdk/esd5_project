
module top
#(
		parameter WORD_LENGTH = 12, 
		parameter Y_WORD_LENGTH = WORD_LENGTH*2+3 //the wordlencth of output. should be double size
)
(   
    //inout of commul
		input signed[WORD_LENGTH-1:0] I_x1, I_x2, I_x3, I_x4, // input of the sample real 
		input signed[WORD_LENGTH-1:0] Q_x1, Q_x2, Q_x3, Q_x4, //input smaple imag 
		input signed[WORD_LENGTH-1:0] I_s1, I_s2, I_s3, I_s4, //real steering vedtor
		input signed[WORD_LENGTH-1:0] Q_s1, Q_s2, Q_s3, Q_s4,	//imag steeing vector
		output wire real y_abs_sq_cmul 			//output real imag  

); 

abs_sq_cmul #(
    .WORD_LENGTH(WORD_LENGTH),
    .Y_WORD_LENGTH(Y_WORD_LENGTH)
)abs_sq_cmul (
    .I_x1(I_x1), .I_x2(I_x2), .I_x3(I_x3), .I_x4(I_x4),
    .Q_x1(Q_x1), .Q_x2(Q_x2), .Q_x3(Q_x3), .Q_x4(Q_x4),
    .I_s1(I_s1), .I_s2(I_s2), .I_s3(I_s3), .I_s4(I_s4),
    .Q_s1(Q_s1), .Q_s2(Q_s2), .Q_s3(Q_s3), .Q_s4(Q_s4),
    .y_abs_sq_cmul(y_abs_sq_cmul)
);




endmodule
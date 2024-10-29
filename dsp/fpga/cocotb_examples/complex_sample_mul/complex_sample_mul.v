//Top module of complex sample multiplication

module complex_sample_mul
#(
		parameter WORD_LENGTH = 12, 
		parameter Y_WORD_LENGTH = WORD_LENGTH*2 //the wordlencth of output. should be double size
)
(   
		input signed[WORD_LENGTH-1:0] I_x1, I_x2, I_x3, I_x4, // input of the sample real 
		input signed[WORD_LENGTH-1:0] Q_x1, Q_x2, Q_x3, Q_x4, //input smaple imag 
		input signed[WORD_LENGTH-1:0] I_s1, I_s2, I_s3, I_s4, //real steering vedtor
		input signed[WORD_LENGTH-1:0] Q_s1, Q_s2, Q_s3, Q_s4,	//imag steeing vector
		output wire signed[Y_WORD_LENGTH-1:0] I_y, Q_y 			//output real imag  
);   

//#####################################
// internal registers
//#####################################	
wire signed[Y_WORD_LENGTH-1:0] I_imm_1, I_imm_2, I_imm_3, I_imm_4;
wire signed[Y_WORD_LENGTH-1:0] Q_imm_1, Q_imm_2, Q_imm_3, Q_imm_4;

//#####################################
// task definitions
//#####################################

function [Y_WORD_LENGTH-1:0] cmulI;
		input signed[WORD_LENGTH-1:0] in_I_x1, in_I_x2, in_Q_x1, in_Q_x2;  	 				
	begin
		cmulI = in_I_x1 * in_I_x2 - in_Q_x1 * in_Q_x2;
	end
endfunction

function [Y_WORD_LENGTH-1:0] cmulQ;
		input signed[WORD_LENGTH-1:0] in_I_x1, in_I_x2;  	 				
		input signed[WORD_LENGTH-1:0] in_Q_x1, in_Q_x2;  	 				
	begin
		cmulQ = in_I_x1 * in_Q_x2 + in_I_x2 * in_Q_x1;
	end
endfunction

//#####################################
// program begins here
//#####################################

assign I_imm_1 = cmulI(I_x1, I_s1, Q_x1, Q_s1);
assign I_imm_2 = cmulI(I_x2, I_s2, Q_x2, Q_s2);
assign I_imm_3 = cmulI(I_x3, I_s3, Q_x3, Q_s3);
assign I_imm_4 = cmulI(I_x4, I_s4, Q_x4, Q_s4);

assign Q_imm_1 = cmulQ(I_x1, I_s1, Q_x1, Q_s1);
assign Q_imm_2 = cmulQ(I_x2, I_s2, Q_x2, Q_s2);
assign Q_imm_3 = cmulQ(I_x3, I_s3, Q_x3, Q_s3);
assign Q_imm_4 = cmulQ(I_x4, I_s4, Q_x4, Q_s4);


assign I_y = I_imm_1 + I_imm_2 + I_imm_3 + I_imm_4;
assign Q_y = Q_imm_1 + Q_imm_2 + Q_imm_3 + Q_imm_4;

endmodule

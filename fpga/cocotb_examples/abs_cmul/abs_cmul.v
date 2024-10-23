//Top module of complex sample multiplication

module abs_cmul
#(
		parameter WORD_LENGTH = 12, 
		parameter Y_WORD_LENGTH = WORD_LENGTH*2+3 //the wordlencth of output. should be double size 
)
(   
		input signed[WORD_LENGTH-1:0] I_x1, I_x2, I_x3, I_x4, // input of the sample real 
		input signed[WORD_LENGTH-1:0] Q_x1, Q_x2, Q_x3, Q_x4, //input smaple imag 
		input signed[WORD_LENGTH-1:0] I_s1, I_s2, I_s3, I_s4, //real steering vedtor
		input signed[WORD_LENGTH-1:0] Q_s1, Q_s2, Q_s3, Q_s4,	//imag steeing vector
		output wire real y_abs_cmul			//output real imag  
);   

//#####################################
// internal registers
//#####################################	
wire signed[Y_WORD_LENGTH-1:0] I_imm1, I_imm2, I_imm3, I_imm4;
wire signed[Y_WORD_LENGTH-1:0] Q_imm1, Q_imm2, Q_imm3, Q_imm4;
wire signed[Y_WORD_LENGTH-1:0] I_tot, Q_tot;


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

function [Y_WORD_LENGTH*2-1:0] sq; //skal være dobbelt længde a Y_WORD_LENGTH da det bliver sqaured
		input signed[Y_WORD_LENGTH-1:0] in_sq;
	begin
		sq = in_sq * in_sq;
	end
endfunction

function real absIQ; // skal bare være Y_WORD_LENGTH grundet root
		input[Y_WORD_LENGTH-1:0] in_I, in_Q;
	begin
		absIQ = $sqrt((in_I*in_I) + (in_Q*in_Q));
	end
endfunction
//#####################################
// program begins here
//#####################################

assign I_imm1 = cmulI(I_x1, I_s1, Q_x1, Q_s1);
assign I_imm2 = cmulI(I_x2, I_s2, Q_x2, Q_s2);
assign I_imm3 = cmulI(I_x3, I_s3, Q_x3, Q_s3);
assign I_imm4 = cmulI(I_x4, I_s4, Q_x4, Q_s4);

assign Q_imm1 = cmulQ(I_x1, I_s1, Q_x1, Q_s1);
assign Q_imm2 = cmulQ(I_x2, I_s2, Q_x2, Q_s2);
assign Q_imm3 = cmulQ(I_x3, I_s3, Q_x3, Q_s3);
assign Q_imm4 = cmulQ(I_x4, I_s4, Q_x4, Q_s4);


assign I_tot = I_imm1 + I_imm2 + I_imm3 + I_imm4;
assign Q_tot = Q_imm1 + Q_imm2 + Q_imm3 + Q_imm4;

assign y_abs_cmul = absIQ(I_tot, Q_tot);

endmodule

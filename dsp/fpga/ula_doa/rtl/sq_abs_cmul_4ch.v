// Module performin combinatorial calculation of square(abs(x1*s1 + x2*s2 + x3*s3 + x4*s4))
module sq_abs_cmul_4ch
#(
		parameter WORD_LENGTH_IN = 16, 
		parameter WORD_LENGTH_CALC = WORD_LENGTH_IN*2+8,    // word length of immediate values
		parameter WORD_LENGTH_INT_ABS_SQ = WORD_LENGTH_CALC*2,  // word length of output
		parameter WORD_LENGTH_OUT = WORD_LENGTH_INT_ABS_SQ
)
(   
		input signed[WORD_LENGTH_IN-1:0] I_x1, I_x2, I_x3, I_x4,       // sample inputs real part
		input signed[WORD_LENGTH_IN-1:0] Q_x1, Q_x2, Q_x3, Q_x4,       //smaple inputs imag part
		input signed[WORD_LENGTH_IN-1:0] I_s1, I_s2, I_s3, I_s4,       // steering vector real part
		input signed[WORD_LENGTH_IN-1:0] Q_s1, Q_s2, Q_s3, Q_s4,       // steering vector imag part
		output wire signed [WORD_LENGTH_OUT-1:0] result_abs_sq_cmul	// output real number
);   

// internal registers
wire signed[WORD_LENGTH_CALC-1:0] I_imm1, I_imm2, I_imm3, I_imm4;
wire signed[WORD_LENGTH_CALC-1:0] Q_imm1, Q_imm2, Q_imm3, Q_imm4;
wire signed[WORD_LENGTH_CALC-1:0] I_tot, Q_tot;
wire signed[WORD_LENGTH_INT_ABS_SQ-1: 0] imm_out;

// helper functions
function [WORD_LENGTH_CALC-1:0] cmulI;
		input signed[WORD_LENGTH_IN-1:0] in_I_x1, in_I_x2, in_Q_x1, in_Q_x2;  	 				
	begin
		cmulI = in_I_x1 * in_I_x2 - in_Q_x1 * in_Q_x2;
	end
endfunction

function [WORD_LENGTH_CALC-1:0] cmulQ;
		input signed[WORD_LENGTH_IN-1:0] in_I_x1, in_I_x2, in_Q_x1, in_Q_x2; 	 				  	 				
	begin
		cmulQ = in_I_x1 * in_Q_x2 + in_I_x2 * in_Q_x1;
	end
endfunction

function [WORD_LENGTH_INT_ABS_SQ-1:0] abs_sqIQ;
		input signed[WORD_LENGTH_CALC-1:0] in_I, in_Q;
	begin
		abs_sqIQ = (in_I*in_I) + (in_Q*in_Q);
	end
endfunction

// immediate values
assign I_imm1 = cmulI(I_x1, I_s1, Q_x1, Q_s1);
assign I_imm2 = cmulI(I_x2, I_s2, Q_x2, Q_s2);
assign I_imm3 = cmulI(I_x3, I_s3, Q_x3, Q_s3);
assign I_imm4 = cmulI(I_x4, I_s4, Q_x4, Q_s4);

assign Q_imm1 = cmulQ(I_x1, I_s1, Q_x1, Q_s1);
assign Q_imm2 = cmulQ(I_x2, I_s2, Q_x2, Q_s2);
assign Q_imm3 = cmulQ(I_x3, I_s3, Q_x3, Q_s3);
assign Q_imm4 = cmulQ(I_x4, I_s4, Q_x4, Q_s4);

// sums
assign I_tot = I_imm1 + I_imm2 + I_imm3 + I_imm4;
assign Q_tot = Q_imm1 + Q_imm2 + Q_imm3 + Q_imm4;

// output
assign imm_out = abs_sqIQ(I_tot, Q_tot);
assign result_abs_sq_cmul = imm_out[WORD_LENGTH_INT_ABS_SQ-1 -: WORD_LENGTH_OUT];

endmodule

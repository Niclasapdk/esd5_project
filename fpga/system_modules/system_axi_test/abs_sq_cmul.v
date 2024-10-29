//Top module of complex sample multiplication

module abs_sq_cmul
#(
		parameter WORD_LENGTH = 16, 
		parameter WORD_LENGTH_CALC = WORD_LENGTH*2+3, //the wordlencth of calculations due to the tot sum of IQ
		parameter WORD_LENGTH_OUT = WORD_LENGTH_CALC*2+1 // output is double plus one due to abs_sqIQ function
)
(   
		input signed[WORD_LENGTH-1:0] I_x1, I_x2, I_x3, I_x4, // input of the sample real 
		input signed[WORD_LENGTH-1:0] Q_x1, Q_x2, Q_x3, Q_x4, //input smaple imag 
		input signed[WORD_LENGTH-1:0] I_s1, I_s2, I_s3, I_s4, //real steering vedtor
		input signed[WORD_LENGTH-1:0] Q_s1, Q_s2, Q_s3, Q_s4,	//imag steeing vector
		output wire signed [WORD_LENGTH_OUT-1:0] result_out			//output real imag  
);   

//#####################################
// internal registers
//#####################################	
wire signed[WORD_LENGTH_CALC-1:0] I_imm1, I_imm2, I_imm3, I_imm4;
wire signed[WORD_LENGTH_CALC-1:0] Q_imm1, Q_imm2, Q_imm3, Q_imm4;
wire signed[WORD_LENGTH_CALC-1:0] I_tot, Q_tot;

reg signed[WORD_LENGTH_CALC-1:0] I_imm1_reg, I_imm2_reg, I_imm3_reg, I_imm4_reg;
reg signed[WORD_LENGTH_CALC-1:0] Q_imm1_reg, Q_imm2_reg, Q_imm3_reg, Q_imm4_reg;
reg signed[WORD_LENGTH_CALC-1:0] I_tot_reg, Q_tot_reg;


//#####################################
// task definitions
//#####################################

function [WORD_LENGTH_CALC-1:0] cmulI;
		input signed[WORD_LENGTH-1:0] in_I_x1, in_I_x2, in_Q_x1, in_Q_x2;  	 				
	begin
		cmulI = in_I_x1 * in_I_x2 - in_Q_x1 * in_Q_x2;
	end
endfunction

function [WORD_LENGTH_CALC-1:0] cmulQ;
		input signed[WORD_LENGTH-1:0] in_I_x1, in_I_x2, in_Q_x1, in_Q_x2; 	 				  	 				
	begin
		cmulQ = in_I_x1 * in_Q_x2 + in_I_x2 * in_Q_x1;
	end
endfunction

function [WORD_LENGTH_OUT-1:0] abs_sqIQ; // skal bare være WORD_LENGTH_CALC grundet root
		input signed[WORD_LENGTH_CALC-1:0] in_I, in_Q;
	begin
		abs_sqIQ = (in_I*in_I) + (in_Q*in_Q);
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

	assign result_out = abs_sqIQ(I_tot, Q_tot);


endmodule

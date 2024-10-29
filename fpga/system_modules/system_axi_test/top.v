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
		output wire signed [WORD_LENGTH_OUT-1:0] cmul_out,			//output real imag 

        //input ma module
        input wire rst, en, clk,
        input wire [WORD_LENGTH_OUT-1 : 0] ma_in,
        input wire s_ma_tvalid, s_ma_tlast,
        output wire s_ma_tready,
        input wire m_ma_tready,
        output wire m_ma_tvalid, m_ma_tlast,
	    input wire[WORD_LENGTH_OUT-1 : 0] s_ma_tdata_in, // input of the sample real 
	    output wire [WORD_LENGTH_OUT-1 : 0] m_ma_tdata_out 			//output real imag   
);

abs_sq_cmul #(
    .WORD_LENGTH(WORD_LENGTH),
    .WORD_LENGTH_OUT(WORD_LENGTH_OUT)
)abs_sq_cmul (
    .I_x1(I_x1), .I_x2(I_x2), .I_x3(I_x3), .I_x4(I_x4),
    .Q_x1(Q_x1), .Q_x2(Q_x2), .Q_x3(Q_x3), .Q_x4(Q_x4),
    .I_s1(I_s1), .I_s2(I_s2), .I_s3(I_s3), .I_s4(I_s4),
    .Q_s1(Q_s1), .Q_s2(Q_s2), .Q_s3(Q_s3), .Q_s4(Q_s4),
    .result_out(cmul_out)
);

ma #(
    .WORD_LENGTH_IN_FROM_CMUL(WORD_LENGTH_OUT)
) ma (
    .rst(rst),
    .en(en),
    .clk(clk),
    .ma_in(ma_in),
    .s_ma_tvalid(s_ma_tvalid), .s_ma_tready(s_ma_tready), 
    .s_ma_tlast(s_ma_tlast), .s_ma_tdata_in(s_ma_tdata_in),
    .m_ma_tvalid(m_ma_tvalid), .m_ma_tready(m_ma_tready), 
    .m_ma_tlast(m_ma_tlast), .m_ma_tdata_out(m_ma_tdata_out)
);

//##################################
//program
//##################################
assign s_ma_tdata_in = cmul_out;

endmodule

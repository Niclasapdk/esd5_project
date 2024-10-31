module iverilog_dump();
initial begin
    $dumpfile("moving_average.fst");
    $dumpvars(0, moving_average);
end
endmodule

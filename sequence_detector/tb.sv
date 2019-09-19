module tb;
    logic clk, reset;
    wire shift_match, sm_match;

    seq_shift seq_shift (.clk(clk), .reset(reset), .d(d), .match(shift_match));
    seq_sm seq_sm (.clk(clk), .reset(reset), .d(d), .match(seq_match));

    c_match_pattern: cover property(@(posedge clk) disable iff (reset)
        d ##1 ~d ##1 d ##1 d
    );

    a_identical_output: assert property(@(posedge clk) disable iff (reset)
        shift_match == seq_match 
    );

endmodule

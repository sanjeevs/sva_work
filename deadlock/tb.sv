module tb;
    bit clk, reset;
    logic gnt;

    reg gnt_r;

    // Stupid problem with modelling sender flip flop
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            gnt_r <= 1'b0;
        end 
        else begin
            gnt_r <= gnt;
        end
    end
 
    dut dut(.clk(clk), .reset(reset), .gnt(gnt_r));

    // Ensure that gnt is never asserted consecutively for 8 clocks
    beh_gnt_width: assume property(@(posedge clk) disable iff (reset)
        $rose(gnt_r) |-> gnt_r[->7]##1!gnt_r
    );



endmodule

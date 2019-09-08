// Count that there are 5 non consecutive repition of sig2 while sig1 is asserted. 
module tb;
    logic clk, sig1, sig2, sig3;

    initial clk = 1'b0;
    always #1 clk = !clk;

    initial begin
        {sig1, sig2, sig3} = 3'b0;
        @(posedge clk);
        sig1 = 1'b1;
        sig3 = 1'b1;
        for(int i = 0; i < 5; i++) begin
            @(posedge clk);
            sig2 = 1'b1;
            repeat(1) @(posedge clk);
            sig2 = 1'b0;
        end
        repeat(1) @(posedge clk);
        sig1 = 1'b0;
        repeat(3) @(posedge clk);
        sig3 = 1'b1;
        repeat(1) @(posedge clk);
        sig3 = 1'b0;
        repeat(5) @(posedge clk);
        $finish;
    end

    initial begin
        $recordfile("verilog.trn");
        $recordvars();
    end

    // Note that the finish time of the sequence is when the longer sequence finishes.
    a_and1: assert property(@(posedge clk)
       $rose(sig1) |=> (##2 sig2[=3]) and sig3[*11]
    );

    // Note that only one of the sequence must be true and the end time is when the smaller
    // sequence ends.
    a_or1: assert property(@(posedge clk)
       $rose(sig1) |=> sig2[=3] or !sig3
    );
    
    a_dbg: assert property(@(posedge clk)
       $rose(sig1) |=> sig3[*6]
    );
   
    // Need to start and finish at the same time. 
    a_intersect1: assert property(@(posedge clk)
       $rose(sig1) |=> sig2[=3] intersect sig3[*6]
    );
endmodule        

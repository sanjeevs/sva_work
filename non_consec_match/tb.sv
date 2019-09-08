// Count that there are 5 non consecutive repition of sig2 while sig1 is asserted. 
module tb;
    logic clk, sig1, sig2, sig3;

    initial clk = 1'b0;
    always #1 clk = !clk;

    initial begin
        {sig1, sig2, sig3} = 3'b0;
        @(posedge clk);
        sig1 = 1'b1;
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

    a_non_consec: assert property(@(posedge clk)
       $rose(sig1) |-> sig2[=5] 
    );

    // This is beautiful. The qualifying event sig3 comes much later
    // but the assertion checks the min time and so matches.
    a_qual_non_consec_: assert property(@(posedge clk)
       $rose(sig1) |-> sig2[=5] ##1 sig3
    );

    a_qual_never_finishes_: assert property(@(posedge clk)
       $rose(sig1) |-> sig2[=5] ##10 sig3
    );

    a_consec_rep: assert property(@(posedge clk)
        $rose(sig1) |-> ##[1:$]$rose(sig2) ##[1:$]$rose(sig2) ##[1:$]$rose(sig2) ##[1:$]$rose(sig2)
                        ##[1:$]$rose(sig2)
    );

    a_goto: assert property(@(posedge clk)
       $rose(sig1) |-> sig2[->5] 
    );

    // This is beautiful. The qualifying event sig3 comes much later
    // but the assertion checks the min time and so matches.
    a_qual_goto: assert property(@(posedge clk)
       $rose(sig1) |-> sig2[->5] ##5 sig3
    );
endmodule        

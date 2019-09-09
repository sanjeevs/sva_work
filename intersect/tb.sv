// Count that there are 5 non consecutive repition of sig2 while sig1 is asserted. 
module tb;
    logic clk, CPU_start, READ_complete, CPU_end;

    initial clk = 1'b0;
    always #1 clk = !clk;

    initial begin
        CPU_start = 1'b0;
        READ_complete = 1'b0;
        CPU_end = 1'b0;
        @(posedge clk);
        CPU_start = 1'b1;
        @(posedge clk);
        CPU_start = 1'b0;
        repeat(2) @(posedge clk);

        READ_complete = 1'b1;
        @(posedge clk);
        READ_complete = 1'b0;
        repeat(2) @(posedge clk);

        READ_complete = 1'b1;
        @(posedge clk);
        READ_complete = 1'b0;
        @(posedge clk);

        CPU_end = 1'b1;
        READ_complete = 1'b1;
        @(posedge clk);
        CPU_end = 1'b0;
        READ_complete = 1'b0;
        repeat(2) @(posedge clk);
        $finish;
    end

    initial begin
        $recordfile("verilog.trn");
        $recordvars();
    end

    property checkNumRW;
    @(posedge clk)
        $rose(CPU_start) |-> READ_complete[=3] intersect (!CPU_end[*1:$] ##1 $rose(CPU_end));
    endproperty

    a_checkNumRW: assert property(checkNumRW);
endmodule        

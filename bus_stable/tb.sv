// Count that there are 5 non consecutive repition of sig2 while sig1 is asserted. 
module tb;
    logic clk, req, gnt;
    logic [31:0] bus;

    initial clk = 1'b0;
    always #1 clk = !clk;

    initial begin
        req = 1'b0; gnt = 1'b0; bus = 'd0;
        @(posedge clk);
        req = 1'b1;
        bus = 32'hf00dcafe;
        repeat(5) @(posedge clk);
        @(posedge clk);
        gnt = 1'b1;
        @(posedge clk);
        req = 1'b0;
        bus = 32'h0;
        gnt = 1'b0;
        @(posedge clk);
        repeat(3) @(posedge clk);
        $finish;
    end

    initial begin
        $recordfile("verilog.trn");
        $recordvars();
    end

    // Check that the data bus does not change when req is asserted.
    a_bus_stable_req: assert property(@(posedge clk)
        $rose(req) |=> (bus == $past(bus)) throughout (req[*0:$] ##1 $rose(gnt))
    ); 
    a_bus_stable_gnt: assert property(@(posedge clk)
        $rose(req) |=> (bus == $past(bus)) throughout (gnt[=1])
    ); 

    // Check that the data bus changes at the end of req.
    a_bus_fell: assert property(@(posedge clk)
        $rose(gnt) |=> (bus != $past(bus) && bus == 'd0)
    );

    // Can also make a timing window for the grant to be asserted within that.
    a_gnt_window: assert property(@(posedge clk)
        $rose(req) |-> 1[*1:7] intersect (req[*1:$] ##1 $rose(gnt))
    );

    // Request must be asserted till grant is asserted.
    a_req_hold: assert property(@(posedge clk)
        (req & !gnt) |=> req
    );

endmodule        

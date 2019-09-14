module tb;
    logic wclk=1'b0;
    logic rclk=1'b0;
    logic reset_w, reset_r;

    always #5 wclk = ~wclk;
    always #10 rclk = ~rclk;

    write_intf_t write_intf(wclk, reset_w);
    read_intf_t read_intf(rclk, reset_r);

//    fifo1 dut(.write_intf(write_intf.mr), .read_intf(read_intf.mr));

    fifo2 dut(.wclk(write_intf.mr.wclk), .wreset(write_intf.reset),
              .push(write_intf.dut.push), .full(write_intf.dut.full),
              .rclk(read_intf.rclk), .rreset(read_intf.reset),
              .pop(read_intf.dut.pop), .empty(read_intf.dut.empty));



    initial begin
        $display(">>>Asserting write reset");
        reset_w = 1'b1;
        repeat (2) @(posedge wclk);
        @(negedge wclk);
        reset_w = 1'b0;
    end 

    initial begin
        $display(">>>Asserting read reset");
        reset_r = 1'b1;
        repeat (2) @(posedge rclk);
        @(negedge rclk);
        reset_r = 1'b0;
    end 

    initial begin
        write_intf.md.driver_cb.push <= 1'b0;
        read_intf.md.driver_cb.pop <= 1'b0;
        fork
            repeat (5) @(posedge wclk);
            repeat (5) @(posedge rclk);
        join
        $display("@@@[%0t]:Starting test", $stime);
        @write_intf.md.driver_cb;
        $display("@@@[%0t]:Driving push", $stime);
        write_intf.md.driver_cb.push <= 1'b1;
        @write_intf.md.driver_cb;
        @write_intf.md.driver_cb;
        write_intf.md.driver_cb.push <= 1'b0;
        repeat (20) @(posedge wclk);
        $finish();
    end

    initial begin
        @(negedge reset_r);
        forever begin
            wait(read_intf.md.driver_cb.empty == 1'b0);
            @read_intf.md.driver_cb;
            read_intf.md.driver_cb.pop <= 1'b1;
            @read_intf.md.driver_cb;
            read_intf.md.driver_cb.pop <= 1'b0;
            @read_intf.md.driver_cb;
        end 
    end

    initial begin
        $recordfile("verilog.trn");
        $recordvars();
    end

    
    push_protocol: assume property(@(posedge wclk) disable iff(reset_w)
        write_intf.push |-> $past(write_intf.full == 1'b0)
    );
endmodule    

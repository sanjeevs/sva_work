module fv;
    logic wclk,rclk;
    logic reset_w, reset_r;

    write_intf_t write_intf(wclk, reset_w);
    read_intf_t read_intf(rclk, reset_r);

    fifo1 dut(.write_intf(write_intf.mr), .read_intf(read_intf.mr));

    // Push can only be asserted if fifo is not full.
    push_protocol: assume property(@(posedge wclk) disable iff(reset_w)
        !(write_intf.push & write_intf.full)
    );

    // Pop can only be asserted if fifo is not empty
    pop_protocol: assume property(@(posedge rclk) disable iff(reset_r)
        !(read_intf.pop & read_intf.empty)
    );

    // Check that the wptr does not change once full is asserted
    a_wptr_stable: assert property(@(posedge wclk) disable iff(reset_w)
        write_intf.full |=> (dut.wptr == $past(dut.wptr))
    );

    // Check that the rptr does not change once empty is asserted
    a_rptr_stable: assert property(@(posedge rclk) disable iff(reset_r)
        if(!$isunknown($past(dut.rptr)))
            read_intf.empty |=> (dut.rptr == $past(dut.rptr))
    );

    // Check that if fifo is full then it cannot be empty
    // This is not true due to synchronizing delay.
    a_empty_full: assert property(@(posedge rclk) disable iff (reset_w)
         @(posedge rclk) read_intf.empty |=> @(posedge wclk) (!write_intf.full)
    );

    a_full_empty: assert property(@(posedge wclk) disable iff (reset_w)
         @(posedge wclk) write_intf.full |=> @(posedge rclk) (!read_intf.empty)
    );

    // Check that after reset the empty signal is a 1.
    reg active;
    always_ff @(posedge wclk or posedge reset_w) begin
        if(reset_w)
            active <= 1'b0;
        else
            active <= 1'b1;
    end
    a_empty_reset: assert property(@(posedge rclk)
        !active |-> read_intf.empty
    );

    // Overflow test
    int cnt;
    always@(posedge wclk or posedge reset_w) begin
        if(reset_w) begin
            cnt <= 'd0;
        end
        else begin
            case({write_intf.push, read_intf.pop})
                2'b01: cnt <= cnt - 'd1;
                2'b10: cnt <= cnt + 'd1;
                default: cnt <= cnt;
            endcase
        end
    end 
    //a_overflow_fifo1: assert property(@(posedge wclk) disable iff(reset_w)
    //    cnt <= 'd2    
    //);
    a_underflow: assert property(@(posedge wclk) disable iff(reset_w)
        cnt >= 'd0    
    );

endmodule

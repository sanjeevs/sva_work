//
// A more optimized version
// Here we are using only a single bit pointer and so we don't need grey encoding,
// However we are limited to a single storage.
module fifo2(input logic wclk, input logic wreset, input push, output logic full,
             input logic rclk, input logic rreset, input pop, output logic empty);

    logic wptr_nxt, wptr, wptr_rclk;
    logic rptr_nxt, rptr, rptr_wclk;
    
    always_comb begin
        wptr_nxt = push ^ wptr;
    end

    always_ff @(posedge wclk or posedge wreset) begin
        if(wreset) begin
            wptr <= 'd0;
        end
        else begin
            wptr <= wptr_nxt;
        end
    end
    always_comb begin
        full <= (wptr ^ rptr_wclk);
    end
 

    // Read logic
    //
    always_comb begin
        rptr_nxt = pop ^ rptr;
    end

    always_ff @(posedge rclk or posedge rreset) begin
        if(rreset) begin
            rptr <= 'd0;
        end
        else begin
            rptr <= rptr_nxt;
        end
    end
    
    always_ff @(posedge rclk or posedge rreset) begin
        if(rreset) begin
            empty <= 'd1;
        end
        else if(!empty) begin
            empty <= ((rptr ^wptr_rclk) & pop);
        end
        else if(empty) begin
            empty <= (rptr == wptr_rclk) ? 1'b1 : 1'b0;
        end
    end

    synch_ff2 #(1) wptr_synch (.clk(rclk), .reset(rreset), .d(wptr), .q(wptr_rclk));
    synch_ff2 #(1) rptr_synch (.clk(wclk), .reset(wreset), .d(rptr), .q(rptr_wclk));
endmodule

//
// Classic Async fifo with no optimization for depth of 2.
// Should work for all possible depth sizes
//
module fifo1(write_intf_t.mr write_intf, read_intf_t.mr read_intf);
    logic [1:0] wptr_nxt, wptr, wptr_s;
    logic [1:0] wptr_grey_nxt, wptr_grey, wptr_grey_s;
    logic[1:0] rptr_nxt, rptr, rptr_s;
    logic[1:0] rptr_grey_nxt, rptr_grey, rptr_grey_s;

    logic full_nxt, empty_nxt;
    wire rclk, wclk;

    assign wclk = write_intf.wclk;
    assign rclk = read_intf.rclk;

    // 
    // Write Pointer Logic
    //
    always_comb begin
        wptr_nxt <= write_intf.rcvr_cb.push ? (wptr + 'd1) : wptr;
    end
    always_comb begin
        wptr_grey_nxt <= bin2grey(wptr_nxt);
    end
    always_ff@(posedge wclk or posedge write_intf.reset) begin
        if(write_intf.reset) begin
            wptr <= 'd0;
            wptr_grey <= 'd0;
        end
        else begin
            wptr <= wptr_nxt;
            wptr_grey <= wptr_grey_nxt;
        end
    end
 
    synch_ff2#(2) wptr_sync(.clk(rclk), .reset(read_intf.reset), .d(wptr_grey), 
                                  .q(wptr_grey_s)); 
    always_comb begin
        wptr_s <= grey2bin(wptr_grey_s);
    end

    always_comb begin
        full_nxt <= diff_max(wptr_nxt, rptr_s);
    end

    always_ff@(posedge wclk) begin
        write_intf.rcvr_cb.full <= full_nxt;
    end
    // 
    // Read Pointer Logic
    //
    always_comb begin
        rptr_nxt <= read_intf.rcvr_cb.pop ? (rptr + 'd1) : rptr;
    end
    always_comb begin
        rptr_grey_nxt <= bin2grey(rptr_nxt);
    end
    always_ff@(posedge rclk or posedge read_intf.reset) begin
        if(read_intf.reset) begin
            rptr <= 'd0;
            rptr_grey <= 'd0;
        end
        else begin
            rptr <= rptr_nxt;
            rptr_grey <= rptr_grey_nxt;
        end
    end
 
    synch_ff2#(2) rptr_sync(.clk(wclk), .reset(write_intf.reset), .d(rptr_grey), 
                                  .q(rptr_grey_s)); 
    always_comb begin
        rptr_s <= grey2bin(rptr_grey_s);
    end

    always_comb begin
        empty_nxt = (rptr_nxt == wptr_s);
    end

    always_ff @(posedge rclk or posedge read_intf.reset) begin
        if(read_intf.reset) begin
            read_intf.rcvr_cb.empty <= 1'b1;
        end
        else begin    
            read_intf.rcvr_cb.empty <= empty_nxt;
        end
    end

    function bit diff_max(bit[1:0] a, bit[1:0] b);
        return (a == {~b[1], b[0]});
    endfunction

    function bit[1:0] bin2grey(bit[1:0] in);
        case(in)
            2'd0: bin2grey = 2'd0;
            2'd1: bin2grey = 2'd2;
            2'd2: bin2grey = 2'd3;
            2'd3: bin2grey = 2'd1;
        endcase
    endfunction

    function bit[1:0] grey2bin(bit[1:0] in);
        case(in)
            2'd0: grey2bin = 2'd0;
            2'd1: grey2bin = 2'd3;
            2'd2: grey2bin = 2'd1;
            2'd3: grey2bin = 2'd2;
        endcase
    endfunction

    property grey_encoding(clk, reset, din);
        @(posedge clk) disable iff (reset) !$stable(din) |-> $onehot(din ^ $past(din));
    endproperty

    a_wptr_grey: assert property(grey_encoding(wclk, write_intf.reset, wptr_grey));
    a_rptr_grey: assert property(grey_encoding(rclk, read_intf.reset, rptr_grey));
endmodule

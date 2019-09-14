// 2 stage ff synchronizer
// The input must be asserted for at least 3 positive edges.
//
module synch_ff2 #(parameter int WIDTH=1)(input clk, input reset, 
                                          input logic[WIDTH-1:0] d, 
                                          output logic[WIDTH-1:0] q);
    logic [WIDTH-1:0] d1;
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            d1 <= 'b0;
            q <= 'b0;
        end
        else begin
            d1 <= d;
            q <= d1; 
        end
    end
`ifdef SIMON
    property p_no_glitch;
        bit value;
        @(posedge d) (1, value=~d[0]) |-> @(posedge clk) (value == d[0]);  
    endproperty

    a_no_glitch: assert property(p_no_glitch);
`endif
// This is not true for lossy synchronizer where we don't care if we lose values.
//    assert property(@(posedge clk) disable iff(reset)
//        !$stable(d) |=> $stable(d)[*2] 
//    );
endmodule

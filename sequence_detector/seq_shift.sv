module seq_shift(input clk, input reset, input d, output logic match);
    logic [2:0] shift;

    always_ff@(posedge clk or posedge reset) begin
        if(reset) begin
            shift <= 'd0;
        end
        else if(match) begin
            shift <= {2'd0, d};
        end else begin
            shift <= {shift[1:0], d};
        end
    end

    always_comb begin
        match = (shift == 'b101) ? 1'b1 : 1'b0;
    end
endmodule
 

module seq_sm(input clk, input reset, input d, output logic match);
    typedef enum bit[1:0] {S0, S1, S2, S3} state_t;
    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= S0;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case(state)
            S0: if(d == 'b1) next_state <= S1;
            S1: if(d == 'b0) next_state <= S2;
            S2: if(d == 'b1) next_state <= S3;
                else next_state <= S0;
            S3: if(d == 1'b1) next_state <= S1;
                else next_state <= S0;
        endcase
    end

    always_comb begin
        match <= (state == S3) ? 1'b1 : 1'b0;
    end
endmodule

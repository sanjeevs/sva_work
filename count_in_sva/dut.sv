//
// Respond with as many consecutive grants as requested.
// The last grant will be qualified with the 'last' signal. 

module dut(input bit clk, input logic reset, input logic req, input [2:0] num_grants,
            output logic gnt, output logic last);
    typedef enum {SM_IDLE, SM_ACTIVE} state_t;
    state_t state, next_state;

    reg [3:0] cnt;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= SM_IDLE;
        end 
        else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            cnt <= 'd0;
        end 
        else if(req) begin
            cnt <= (num_grants == 0) ? 'd8 : num_grants;
        end
        else begin
            cnt <= (cnt == 0) ? cnt : cnt -1;
        end
    end
    assign last = (state == SM_ACTIVE && cnt == 'd1) ? 1'b1 : 1'b0;
    always_comb begin
        next_state = state;
        case(state)
            SM_IDLE: if(req) next_state = SM_ACTIVE;
            SM_ACTIVE: if(cnt == 'd1) next_state = SM_IDLE;
        endcase
    end

    assign gnt = (state == SM_ACTIVE) ? 1'b1 : 1'b0;
endmodule

// 
// This state machine tracks the grant
//

module dut(input bit clk, input bit reset, input logic gnt);

    typedef enum logic {IDLE, ACTIVE} state_t;

    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case(state)
            IDLE: if(gnt) next_state = ACTIVE;
            ACTIVE: if(!gnt) next_state = IDLE;
        endcase
    end

    // Assertion valid for state machines with more states. Check that there is no
    // transition instead of ACTIVE
    // Note that the precondition which is a automatic coverpoint will not fire for the passing case.
    // This might be a problem.
    a_deadlock: assert property(@(posedge clk) disable iff(reset)
        ((state != IDLE) && $stable(state)) [*7] |-> 1'b0 
    );

endmodule

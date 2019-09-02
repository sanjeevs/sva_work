module tb;
    logic req, gnt;
    logic [2:0] num_grants;
    logic last;
    logic clk, reset;
    reg req_r;

    // sender logic has a flop that is cleared at reset.
    always@(posedge clk or posedge reset) begin
        if(reset)
            req_r <=  1'b0;
        else
            req_r <= req;
    end

    dut dut (.clk(clk), .reset(reset), .req(req_r), .gnt(gnt), .num_grants(num_grants), 
             .last(last));

    property p_consec_grant;
        bit[2:0] cnt;
        ($rose(req_r), cnt=num_grants) |=> gnt[*num_grants];
    endproperty 

    a_consec_grant: assert property(@(posedge clk) disable iff(reset) p_consec_grant);


    c_debug_grant_1: cover property(@(posedge clk) disable iff(reset) $rose(gnt));

    a_req_protocol: assume property(@(posedge clk) disable iff(reset)
        $rose(req_r) |=> req_r[*1:$] ##0 $rose(last) ##1 $fell(req_r)
    );
    a_num_grants_2 : assume property(@(posedge clk) num_grants == 'd2);

endmodule 

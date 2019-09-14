interface write_intf_t(input wclk, input reset);
    logic push;
    logic full;

    clocking driver_cb @(posedge wclk);
        output push;
        input full;
    endclocking

    clocking rcvr_cb @(posedge wclk);
        input push;
        output full;
    endclocking

    modport md(clocking driver_cb, input wclk, input reset);
 
    modport mr(clocking rcvr_cb, input wclk, input reset);

endinterface

interface read_intf_t(input rclk, input reset);
    logic pop;
    logic empty;

    clocking driver_cb @(posedge rclk);
        output pop;
        input empty;
    endclocking

    clocking rcvr_cb @(posedge rclk); 
        input pop;
        output empty;
    endclocking

    modport md(clocking driver_cb, input rclk, input reset); 
    modport mr(clocking rcvr_cb, input rclk, input reset); 

endinterface

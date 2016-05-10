// --------------------------------------------------------------------------------
//  SimpleBus_If
// --------------------------------------------------------------------------------
interface SimpleBus_If(input clk, input rst_n);

    logic        bus_cmd_valid;
    logic        bus_op;
    logic [15:0] bus_addr;
    logic [15:0] bus_wr_data;
    logic [15:0] bus_rd_data;
    logic [7:0]  rxd;
    logic        rx_dv;
    logic [7:0]  txd;
    logic        tx_en;

    clocking cb_bus_input @(posedge clk);
        output bus_cmd_valid;
        output bus_op;
        output bus_addr;
        output bus_wr_data;
    endclocking

    clocking cb_bus_output @(posedge clk);
        input bus_cmd_valid;
        input bus_op;
        input bus_addr;
        input bus_wr_data;
        input bus_rd_data;
    endclocking

    clocking cb_dut_input_dri @(posedge clk);
        output rxd;
        output rx_dv;
    endclocking

    clocking cb_dut_input_mon @(posedge clk);
        input rxd;
        input rx_dv;
    endclocking

    clocking cb_dut_output_mon @(posedge clk);
        input  txd;
        input  tx_en;
    endclocking

    modport bus_input(clocking cb_bus_input, input rst_n);
    modport bus_output(clocking cb_bus_output, input rst_n);
    modport dut_input_dri(clocking cb_dut_input_dri, input rst_n);
    modport dut_input_mon(clocking cb_dut_input_mon, input rst_n);
    modport dut_output_mon(clocking cb_dut_output_mon, input rst_n);

endinterface : SimpleBus_If

// --------------------------------------------------------------------------------
//  TOP Module
// --------------------------------------------------------------------------------
module top;
    reg clk;
    reg rst_n;

    SimpleBus_If bus_dut_if(clk, rst_n);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        // Interface connect testbench and dut
        uvm_config_db #(virtual SimpleBus_If.dut_input_dri)::set(null, "uvm_test_top.env.dut_agent_h_i.dut_dri_h", "dut_input_dri_vif", bus_dut_if.dut_input_dri);
        uvm_config_db #(virtual SimpleBus_If.dut_input_mon)::set(null, "uvm_test_top.env.dut_agent_h_i.dut_mon_i_h", "dut_input_mon_vif", bus_dut_if.dut_input_mon);
        uvm_config_db #(virtual SimpleBus_If.dut_output_mon)::set(null, "uvm_test_top.env.dut_agent_h_o.dut_mon_o_h", "dut_output_mon_vif", bus_dut_if.dut_output_mon);

        // Interface connect testbench and bus
        uvm_config_db #(virtual SimpleBus_If.bus_input)::set(null, "uvm_test_top.env.bus_agent_h.bus_dri_h", "bus_input_dri_vif", bus_dut_if.bus_input);
        uvm_config_db #(virtual SimpleBus_If.bus_output)::set(null, "uvm_test_top.env.bus_agent_h.bus_mon_h", "bus_output_mon_vif", bus_dut_if.bus_output);

        run_test("SimpleBus_Test");
    end

    dut test_dut (
                  .clk           (clk),
                  .rst_n         (rst_n),
                  .bus_cmd_valid (bus_dut_if.bus_cmd_valid),
                  .bus_op        (bus_dut_if.bus_op),
                  .bus_addr      (bus_dut_if.bus_addr),
                  .bus_wr_data   (bus_dut_if.bus_wr_data),
                  .bus_rd_data   (bus_dut_if.bus_rd_data),
                  .rxd           (bus_dut_if.rxd),
                  .rx_dv         (bus_dut_if.rx_dv),
                  .txd           (bus_dut_if.txd),
                  .tx_en         (bus_dut_if.tx_en));

    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst_n = 1'b0;
        #100
        rst_n = 1'b1;
    end
endmodule : top

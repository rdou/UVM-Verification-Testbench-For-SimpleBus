// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Driver
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Driver extends uvm_driver #(SimpleBus_Bus_Transaction);
    `uvm_component_utils(SimpleBus_Bus_Driver)

    virtual SimpleBus_If.bus_input bus_dri_vif;
    SimpleBus_Bus_Transaction bus_dri_tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        assert(uvm_config_db #(virtual SimpleBus_If.bus_input)::get(this, "", "bus_input_dri_vif", bus_dri_vif))
        else begin
            `uvm_fatal("Bus Driver", "Failed to get SimpleBus_If");
        end
    endfunction

    task drive_one_block(SimpleBus_Bus_Transaction bus_dri_tr);
        @bus_dri_vif.cb_bus_input;
        bus_dri_vif.cb_bus_input.bus_cmd_valid <= 1'b1;
        bus_dri_vif.cb_bus_input.bus_op <= (bus_dri_tr.bus_op == BUS_RD ? 0 : 1);
        bus_dri_vif.cb_bus_input.bus_addr <= bus_dri_tr.bus_addr;
        bus_dri_vif.cb_bus_input.bus_wr_data <= bus_dri_tr.bus_wr_data;

        @bus_dri_vif.cb_bus_input;
        bus_dri_vif.cb_bus_input.bus_cmd_valid <= 1'b0;
        bus_dri_vif.cb_bus_input.bus_op <= 1'b0;
        bus_dri_vif.cb_bus_input.bus_addr <= 16'b0;
        bus_dri_vif.cb_bus_input.bus_wr_data <= 16'b0;
    endtask

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_name(), "Bus driver start working...", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);
        bus_dri_vif.cb_bus_input.bus_cmd_valid <= 1'b0;
        bus_dri_vif.cb_bus_input.bus_op <= 1'b0;
        bus_dri_vif.cb_bus_input.bus_addr <= 16'b0;
        bus_dri_vif.cb_bus_input.bus_wr_data <= 16'b0;

        while (bus_dri_vif.rst_n == 1'b0)
            @(bus_dri_vif.cb_bus_input);

        while (1) begin
            seq_item_port.get_next_item(bus_dri_tr);
            drive_one_block(bus_dri_tr);
            seq_item_port.item_done();
        end
    endtask
endclass : SimpleBus_Bus_Driver

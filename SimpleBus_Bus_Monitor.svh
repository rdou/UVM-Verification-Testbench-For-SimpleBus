// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Monitor
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Monitor extends uvm_monitor;
    `uvm_component_utils(SimpleBus_Bus_Monitor)

    virtual SimpleBus_If.bus_output bus_mon_vif;
    SimpleBus_Bus_Transaction bus_mon_tr;
    uvm_analysis_port #(SimpleBus_Bus_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        assert(uvm_config_db #(virtual SimpleBus_If.bus_output)::get(this, "", "bus_output_mon_vif", bus_mon_vif))
        else begin
            `uvm_fatal("Bus Monitor", "Failed to get SimpleBus_If");
        end
        ap = new("bus_mon_ap", this);
    endfunction

    task collect_one_block(SimpleBus_Bus_Transaction bus_mon_tr);
        while (1) begin
            @(bus_mon_vif.cb_bus_output);
            if (bus_mon_vif.cb_bus_output.bus_cmd_valid == 1'b1) begin
                break;
            end
        end

        bus_mon_tr.bus_op = bus_mon_vif.cb_bus_output.bus_op;
        bus_mon_tr.bus_wr_data = bus_mon_vif.cb_bus_output.bus_wr_data;
        bus_mon_tr.bus_addr = bus_mon_vif.cb_bus_output.bus_addr;

        @(bus_mon_vif.cb_bus_output);
        bus_mon_tr.bus_rd_data = bus_mon_vif.cb_bus_output.bus_rd_data;
    endtask

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_name(), "Bus monitor start working", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);

        while (1) begin
            bus_mon_tr = SimpleBus_Bus_Transaction::type_id::create("bus_mon_tr");
            collect_one_block(bus_mon_tr);
            ap.write(bus_mon_tr);
        end
    endtask
endclass : SimpleBus_Bus_Monitor

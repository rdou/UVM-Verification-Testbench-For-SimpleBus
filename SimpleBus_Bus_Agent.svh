// --------------------------------------------------------------------------------
// SimpleBus_Bus_Agent
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Agent extends uvm_agent;
    `uvm_component_utils(SimpleBus_Bus_Agent)

    // in this example, bus monitor and ap do nothing useful
    SimpleBus_Bus_Driver                           bus_dri_h;
    SimpleBus_Bus_Monitor                          bus_mon_h;
    SimpleBus_Bus_Sequencer                        bus_sqr_h;
    SimpleBus_Bus_Adapter                          bus_adp_h;
    uvm_analysis_port #(SimpleBus_Bus_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            bus_dri_h = SimpleBus_Bus_Driver::type_id::create("bus_dri_h", this);
            bus_sqr_h = SimpleBus_Bus_Sequencer::type_id::create("bus_sqr_h", this);
        end

        bus_mon_h = SimpleBus_Bus_Monitor::type_id::create("bus_mon_h", this);
        bus_adp_h = SimpleBus_Bus_Adapter::type_id::create("bus_adp_h", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            bus_dri_h.seq_item_port.connect(bus_sqr_h.seq_item_export);
        end

        ap = bus_mon_h.ap;
    endfunction
endclass : SimpleBus_Bus_Agent

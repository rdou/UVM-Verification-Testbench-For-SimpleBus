// --------------------------------------------------------------------------------
// SimpleBus_Dut_Agent
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Agent extends uvm_agent;
    `uvm_component_utils(SimpleBus_Dut_Agent)

    SimpleBus_Dut_Input_Monitor                    dut_mon_i_h;
    SimpleBus_Dut_Output_Monitor                   dut_mon_o_h;
    SimpleBus_Dut_Driver                           dut_dri_h;
    SimpleBus_Dut_Sequencer                        dut_sqr_h;
    uvm_analysis_port #(SimpleBus_Dut_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        // ACTIVE agent contains driver, sequencer, monitor and analysis_port;
        // INACTIVE agent contains only monitor and analysis_port
        if (is_active == UVM_ACTIVE) begin
            dut_dri_h   = SimpleBus_Dut_Driver::type_id::create("dut_dri_h", this);
            dut_mon_i_h = SimpleBus_Dut_Input_Monitor::type_id::create("dut_mon_i_h", this);
            dut_sqr_h   = SimpleBus_Dut_Sequencer::type_id::create("dut_sqr_h", this);
        end else begin
            dut_mon_o_h = SimpleBus_Dut_Output_Monitor::type_id::create("dut_mon_o_h", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            dut_dri_h.seq_item_port.connect(dut_sqr_h.seq_item_export);
            ap = dut_mon_i_h.ap;
        end else begin
            ap = dut_mon_o_h.ap;
        end
    endfunction
endclass : SimpleBus_Dut_Agent

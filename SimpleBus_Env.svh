// --------------------------------------------------------------------------------
// SimpleBus_Env
// --------------------------------------------------------------------------------
class SimpleBus_Env extends uvm_env;
    `uvm_component_utils(SimpleBus_Env)

    SimpleBus_Bus_Agent bus_agent_h;
    SimpleBus_Dut_Agent dut_agent_h_i;
    SimpleBus_Dut_Agent dut_agent_h_o;
    SimpleBus_Scoreboard scb_h;
    SimpleBus_reg_predictor reg_predictor_h;
    SimpleBus_reg_model reg_block_h;

    uvm_tlm_analysis_fifo #(SimpleBus_Dut_Transaction) agt_scb_i_fifo;
    uvm_tlm_analysis_fifo #(SimpleBus_Dut_Transaction) agt_scb_o_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        // create objects
        bus_agent_h     = SimpleBus_Bus_Agent::type_id::create("bus_agent_h", this);
        dut_agent_h_i   = SimpleBus_Dut_Agent::type_id::create("dut_agent_h_i", this);
        dut_agent_h_o   = SimpleBus_Dut_Agent::type_id::create("dut_agent_h_o", this);
        scb_h           = SimpleBus_Scoreboard::type_id::create("scb_h", this);
        reg_predictor_h = SimpleBus_reg_predictor::type_id::create("reg_predictor_h", this);
        reg_block_h     = SimpleBus_reg_model::type_id::create("reg_block_h", this);

        // TLM components use new()
        agt_scb_i_fifo  = new("agt_scb_i_fifo", this);
        agt_scb_o_fifo  = new("agt_scb_o_fifo", this);

        // other construction related works
        bus_agent_h.is_active   = UVM_ACTIVE;
        dut_agent_h_i.is_active = UVM_ACTIVE;
        dut_agent_h_o.is_active = UVM_PASSIVE;
        reg_block_h.build();
    endfunction

    function void connect_phase(uvm_phase phase);
        dut_agent_h_i.ap.connect(agt_scb_i_fifo.analysis_export);
        dut_agent_h_o.ap.connect(agt_scb_o_fifo.analysis_export);
        scb_h.exp_port.connect(agt_scb_o_fifo.blocking_get_export);
        scb_h.act_port.connect(agt_scb_i_fifo.blocking_get_export);

        // connect RAL related components
        // only the top level register block calls set_sequencer() 
        if (reg_block_h.get_parent() == null) begin
            reg_block_h.SimpleBus_reg_map.set_sequencer(bus_agent_h.bus_sqr_h, bus_agent_h.bus_adp_h);
        end
        reg_block_h.SimpleBus_reg_map.set_auto_predict(1);
        reg_predictor_h.map     = reg_block_h.SimpleBus_reg_map;
        reg_predictor_h.adapter = bus_agent_h.bus_adp_h;
        bus_agent_h.ap.connect(reg_predictor_h.bus_in);
    endfunction
endclass : SimpleBus_Env

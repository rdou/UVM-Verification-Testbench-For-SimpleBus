// --------------------------------------------------------------------------------
// SimpleBus_Test
// --------------------------------------------------------------------------------
class SimpleBus_Test extends uvm_test;
    `uvm_component_utils(SimpleBus_Test)

    SimpleBus_Env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void vseq_init(SimpleBus_Bus_Dut_Vseq bus_dut_vseq);
        bus_dut_vseq.bus_sqr_h         = env.bus_agent_h.bus_sqr_h;
        bus_dut_vseq.dut_sqr_h         = env.dut_agent_h_i.dut_sqr_h;
        bus_dut_vseq.bus_reg_seq.model = env.reg_block_h;
    endfunction

    function void build_phase(uvm_phase phase);
        env = SimpleBus_Env::type_id::create("env", this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);

        // print classes that are registered in UVM factory
        if (uvm_report_enabled(UVM_HIGH)) begin
            this.print;
            factory.print;
        end
    endfunction

    task run_phase(uvm_phase phase);
        SimpleBus_Bus_Dut_Vseq bus_dut_vseq = SimpleBus_Bus_Dut_Vseq::type_id::create("bus_dut_vseq");

        // start virtual sequences 
        phase.raise_objection(this);
            vseq_init(bus_dut_vseq);
            bus_dut_vseq.start(null);
        phase.drop_objection(this);
    endtask
endclass : SimpleBus_Test

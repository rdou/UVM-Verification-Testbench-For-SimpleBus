// --------------------------------------------------------------------------------
// SimpleBus_Scoreboard
// --------------------------------------------------------------------------------
class SimpleBus_Scoreboard extends uvm_scoreboard;
    `uvm_component_utils(SimpleBus_Scoreboard)

    uvm_blocking_get_port #(SimpleBus_Dut_Transaction) exp_port;
    uvm_blocking_get_port #(SimpleBus_Dut_Transaction) act_port;
    SimpleBus_Dut_Transaction                          exp_tr;
    SimpleBus_Dut_Transaction                          act_tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        exp_port = new("exp_port", this);
        act_port = new("rec_port", this);
    endfunction

    task run_phase(uvm_phase phase);
        int i;

        while (1) begin
            exp_port.get(exp_tr);
            act_port.get(act_tr);

            // print transaction information if expected and received transaction are different
            if (!exp_tr.compare(act_tr)) begin
                for (i = 0; i < exp_tr.pload.size() && i < act_tr.pload.size(); i++) begin
                    `uvm_info("PLOAD MATCH", $sformatf("EXP PLOAD[%d] = %x, ACT PLOAD[%d] = %x", i, exp_tr.pload[i], i, act_tr.pload[i]), UVM_MEDIUM)
                    if (exp_tr.pload[i] != act_tr.pload[i]) begin
                        `uvm_info("PLOAD MISMATCH", $sformatf("EXP PLOAD[%d] = %x, ACT PLOAD[%d] = %x", i, exp_tr.pload[i], i, act_tr.pload[i]), UVM_MEDIUM)
                    end
                end
                `uvm_fatal("DATA MISMATCH", "Exp and Act tr are different!");
            end
        end
    endtask
endclass : SimpleBus_Scoreboard

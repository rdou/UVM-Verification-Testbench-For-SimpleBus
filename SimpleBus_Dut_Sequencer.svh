// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Sequencer
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Sequencer extends uvm_sequencer #(SimpleBus_Dut_Transaction);
    `uvm_component_utils(SimpleBus_Dut_Sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : SimpleBus_Dut_Sequencer

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Sequencer
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Sequencer extends uvm_sequencer #(SimpleBus_Bus_Transaction);
    `uvm_component_utils(SimpleBus_Bus_Sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : SimpleBus_Bus_Sequencer

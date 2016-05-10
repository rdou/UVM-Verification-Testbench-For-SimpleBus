// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Transaction
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Transaction extends uvm_sequence_item;
    `uvm_object_utils(SimpleBus_Bus_Transaction)

    rand logic [15:0] bus_addr;
    rand logic [15:0] bus_wr_data;
    rand bus_op_e    bus_op;

    logic [15:0] bus_rd_data;

    function new(string name = "SimpleBus_Bus_Transaction");
        super.new(name);
    endfunction
endclass : SimpleBus_Bus_Transaction

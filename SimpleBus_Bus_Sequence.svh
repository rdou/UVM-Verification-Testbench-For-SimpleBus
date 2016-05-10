// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Sequence
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Sequence extends uvm_sequence #(SimpleBus_Bus_Transaction);
    `uvm_object_utils(SimpleBus_Bus_Sequence)

    SimpleBus_Bus_Transaction bus_tr;

    function new(string name = "bus_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_name(), "Start sending bus transactions...", UVM_MEDIUM)

        for (int i = 0; i < 10; i++) begin
            bus_tr = SimpleBus_Bus_Transaction::type_id::create("bus_tr");
            start_item(bus_tr);
            assert (bus_tr.randomize())
            else begin
                `uvm_fatal("Bus Sequence", "Failed to randomize SimpleBus_Bus_Transaction")
            end
            finish_item(bus_tr);
        end

        `uvm_info(get_name(), "End of sending bus transactions...", UVM_MEDIUM)
    endtask
endclass : SimpleBus_Bus_Sequence

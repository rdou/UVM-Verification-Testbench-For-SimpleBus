// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Sequence
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Sequence extends uvm_sequence #(SimpleBus_Dut_Transaction);
    `uvm_object_utils(SimpleBus_Dut_Sequence)

    SimpleBus_Dut_Transaction dut_tr;

    function new(string name = "dut_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_name(), "Start sending dut transactions...", UVM_MEDIUM)

        for (int i = 0; i < 10; i++) begin
            dut_tr = SimpleBus_Dut_Transaction::type_id::create("dut_dri_tr");
            start_item(dut_tr);
            assert (dut_tr.randomize())
            else begin
                `uvm_fatal("Dut Sequence", "Failed to randomize SimpleBus_Dut_Transaction")
            end
            finish_item(dut_tr);
        end

        `uvm_info(get_name(), "End of sending dut transactions...", UVM_MEDIUM)
    endtask
endclass : SimpleBus_Dut_Sequence

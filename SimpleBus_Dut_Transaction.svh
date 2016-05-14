// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Transaction
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Transaction extends uvm_sequence_item;
    `uvm_object_utils(SimpleBus_Dut_Transaction)

    rand logic [7:0]   pload[];
    rand logic [31:0] crc;
    rand logic [7:0]   lba;
    rand logic [7:0]   ecc;

    constraint pload_num {
        pload.size >= 64;
        pload.size <= 512;
    }

    function new(string name = "SimpleBus_Dut_Transaction ");
        super.new(name);
    endfunction

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        SimpleBus_Dut_Transaction rhs_;

        if (!$cast(rhs_, rhs)) begin
            return 0;
        end

        if (pload.size() != rhs_.pload.size()) begin
            return 0;
        end else begin
            for (int i = 0; i < pload.size(); i++) begin
                if (pload[i] != rhs_.pload[i]) begin
                    return 0;
                end
            end
        end

        return (super.do_compare(rhs, comparer) &&
               (crc == rhs_.crc) &&
               (lba == rhs_.lba) &&
               (ecc == rhs_.ecc));
    endfunction
endclass : SimpleBus_Dut_Transaction
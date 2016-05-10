// --------------------------------------------------------------------------------
//  SimpleBus_reg_seq
// --------------------------------------------------------------------------------
class SimpleBus_reg_seq extends uvm_reg_sequence;
    `uvm_object_utils(SimpleBus_reg_seq)

    function new( string name = "" );
        super.new( name );
    endfunction: new

    virtual task body();
        SimpleBus_reg_model reg_block_h;
        uvm_status_e        status;
        uvm_reg_data_t      value;
        bit                 invert;
        $cast(reg_block_h, model);

        invert = 1;

        // frontdoor access
        //write_reg(reg_block_h.invert_h, status, invert);
        //read_reg (reg_block_h.invert_h, status, value);

        // backdoor access
        //poke_reg( reg_block_h.invert_h, status, invert);
        write_reg(reg_block_h.invert_h, status, invert);
        #100
        write_reg (reg_block_h.invert_h, status, 0, UVM_BACKDOOR);
        if (status == UVM_NOT_OK) begin
            `uvm_info("RAL", "BACKDOOR WRITE STATUS NOT OK", UVM_MEDIUM)
        end
        //write_reg(reg_block_h.invert_h, status, 0);
        `uvm_info("RAL", "UVM BACKDOOR WRITE DONE...", UVM_MEDIUM)
        #100
        read_reg (reg_block_h.invert_h, status, value, UVM_BACKDOOR);
        `uvm_info("RAL", $sformatf("UVM BACKDOOR READ DONE... Value = 0x%x", value), UVM_MEDIUM)
        if (status == UVM_NOT_OK) begin
            `uvm_info("RAL", "BACKDOOR READ STATUS NOT OK", UVM_MEDIUM)
        end
    endtask: body
endclass

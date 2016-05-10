// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Adapter 
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Adapter extends uvm_reg_adapter;
    `uvm_object_utils(SimpleBus_Bus_Adapter)

    function new(string name="my_adapter");
        super.new(name);
    endfunction

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        SimpleBus_Bus_Transaction reg2bus_tr;

        reg2bus_tr = SimpleBus_Bus_Transaction::type_id::create("reg2bus_tr");
        reg2bus_tr.bus_addr = rw.addr;
        reg2bus_tr.bus_op = (rw.kind == UVM_READ) ? BUS_RD : BUS_WR;

        if (reg2bus_tr.bus_op == BUS_WR)
            reg2bus_tr.bus_wr_data = rw.data;
        return reg2bus_tr;
    endfunction

    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        SimpleBus_Bus_Transaction bus2reg_tr;

        if (!$cast(bus2reg_tr, bus_item)) begin
            `uvm_fatal(get_type_name(), "Provided bus_item is not of the correct type. Expecting bus_transaction")
            return;
        end

        rw.kind = (bus2reg_tr.bus_op == BUS_RD) ? UVM_READ : UVM_WRITE;
        rw.addr = bus2reg_tr.bus_addr;
        // Not sure how to use this part
        //rw.byte_en = 'h3;
        rw.data = (bus2reg_tr.bus_op == BUS_RD) ? bus2reg_tr.bus_rd_data : bus2reg_tr.bus_wr_data;
        rw.status = UVM_IS_OK;
    endfunction
endclass
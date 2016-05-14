// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Driver
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Driver extends uvm_driver #(SimpleBus_Dut_Transaction);
    `uvm_component_utils(SimpleBus_Dut_Driver)

    virtual SimpleBus_If.dut_input_dri dut_dri_vif;
    SimpleBus_Dut_Transaction dut_dri_tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task drive_one_block(SimpleBus_Dut_Transaction dut_dri_tr);
        logic [7:0] packed_data[$];
        int i;

        foreach (dut_dri_tr.pload[i]) begin
            packed_data.push_front(dut_dri_tr.pload[i]);
        end
        packed_data.push_front(dut_dri_tr.crc);
        packed_data.push_front(dut_dri_tr.lba);
        packed_data.push_front(dut_dri_tr.ecc);

        repeat(3) @(dut_dri_vif.cb_dut_input_dri);
        while (packed_data.size()) begin
            @(dut_dri_vif.cb_dut_input_dri);
            dut_dri_vif.cb_dut_input_dri.rx_dv <= 1'b1;
            dut_dri_vif.cb_dut_input_dri.rxd <= packed_data.pop_back();
        end

        @(dut_dri_vif.cb_dut_input_dri);
        dut_dri_vif.cb_dut_input_dri.rx_dv <= 1'b0;
    endtask

    function void build_phase(uvm_phase phase);
        assert (uvm_config_db #(virtual SimpleBus_If.dut_input_dri)::get(this, "", "dut_input_dri_vif", dut_dri_vif))
        else begin
            `uvm_fatal("Dut Driver", "Failed to get SimpleBus_If");
        end
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_name(), "Dut driver start working...", UVM_MEDIUM)
    endfunction

    task run_phase(uvm_phase phase);

        dut_dri_vif.cb_dut_input_dri.rx_dv <= 1'b0;
        dut_dri_vif.cb_dut_input_dri.rxd   <= 8'b0;

        while (!dut_dri_vif.rst_n)
            @(dut_dri_vif.cb_dut_input_dri);

        while (1) begin
            seq_item_port.get_next_item(dut_dri_tr);
            drive_one_block(dut_dri_tr);
            seq_item_port.item_done();
        end
    endtask
endclass : SimpleBus_Dut_Driver

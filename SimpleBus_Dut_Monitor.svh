// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Base_Monitor
// --------------------------------------------------------------------------------
virtual class SimpleBus_Dut_Base_Monitor extends uvm_monitor;
    uvm_analysis_port #(SimpleBus_Dut_Transaction) ap;
    SimpleBus_Dut_Transaction dut_mon_tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // send one transaction needs multiple clocks (8-bit/.cycle)
    // we need to pack all 8-bit data to one transaction before sending it to scoreboard
    virtual task pack_tr(SimpleBus_Dut_Transaction dut_mon_tr, logic [7 : 0] packed_data[$]);
        int i, q_size;

        q_size = packed_data.size() - 3;
        dut_mon_tr.pload = new[q_size];
        for (i = 0; i < q_size; i++)
            dut_mon_tr.pload[i] = packed_data.pop_back;

        dut_mon_tr.crc = packed_data.pop_back;
        dut_mon_tr.lba = packed_data.pop_back;
        dut_mon_tr.ecc = packed_data.pop_back;
    endtask

    // input and output monitor use different method to collect all 8-bit data
    pure virtual task collect_one_block(SimpleBus_Dut_Transaction dut_mon_tr);

    virtual task run_phase(uvm_phase phase);
        while (1) begin
            dut_mon_tr = SimpleBus_Dut_Transaction::type_id::create("dut_mon_tr");
            collect_one_block(dut_mon_tr);
            ap.write(dut_mon_tr);
        end
    endtask
endclass : SimpleBus_Dut_Base_Monitor

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Input_Monitor
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Input_Monitor extends SimpleBus_Dut_Base_Monitor;
    `uvm_component_utils(SimpleBus_Dut_Input_Monitor)

    virtual SimpleBus_If.dut_input_mon dut_mon_i_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task collect_one_block(SimpleBus_Dut_Transaction dut_mon_tr);
        logic [7:0] packed_data[$];
        int i;

        while (1) begin
            @(dut_mon_i_vif.cb_dut_input_mon)

            if (dut_mon_i_vif.cb_dut_input_mon.rx_dv == 1'b1) begin
                break;
            end
        end

        // since we do not know the size of pload, we should first use a queue to collect data,
        // then give the value to transaction
        while (dut_mon_i_vif.cb_dut_input_mon.rx_dv) begin
            packed_data.push_front(dut_mon_i_vif.cb_dut_input_mon.rxd);
            @(dut_mon_i_vif.cb_dut_input_mon);
        end
        pack_tr(dut_mon_tr, packed_data);
    endtask

    function void build_phase(uvm_phase phase);
        assert (uvm_config_db #(virtual SimpleBus_If.dut_input_mon)::get(this, "", "dut_input_mon_vif", dut_mon_i_vif))
        else begin
            `uvm_fatal("Dut Input Monitor", "Failed to get SimpleBus_If");
        end

        ap = new("dut_mon_ap", this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_name(), "Dut input monitor start working...", UVM_MEDIUM)
    endfunction
endclass : SimpleBus_Dut_Input_Monitor

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Output_Monitor
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Output_Monitor extends SimpleBus_Dut_Base_Monitor;
    `uvm_component_utils(SimpleBus_Dut_Output_Monitor)

    virtual SimpleBus_If.dut_output_mon dut_mon_o_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task collect_one_block(SimpleBus_Dut_Transaction dut_mon_tr);
        logic [7:0] packed_data[$];
        int i;

        while (1) begin
            @(dut_mon_o_vif.cb_dut_output_mon)

            if (dut_mon_o_vif.cb_dut_output_mon.tx_en == 1'b1) begin
                break;
            end
        end

        while (dut_mon_o_vif.cb_dut_output_mon.tx_en) begin
            packed_data.push_front(dut_mon_o_vif.cb_dut_output_mon.txd);
            @(dut_mon_o_vif.cb_dut_output_mon);
        end
        pack_tr(dut_mon_tr, packed_data);
    endtask

    function void build_phase(uvm_phase phase);
        assert (uvm_config_db #(virtual SimpleBus_If.dut_output_mon)::get(this, "", "dut_output_mon_vif", dut_mon_o_vif))
        else begin
            `uvm_fatal("Dut Output Monitor", "Failed to get SimpleBus_If");
        end

        ap = new("dut_mon_ap", this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_name(), "Dut output monitor start working...", UVM_MEDIUM)
    endfunction
endclass : SimpleBus_Dut_Output_Monitor

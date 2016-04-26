// --------------------------------------------------------------------------------
//  DUT
// --------------------------------------------------------------------------------
module dut(clk,rst_n,bus_cmd_valid,bus_op,bus_addr,bus_wr_data,bus_rd_data,rxd,rx_dv,txd,tx_en);
input          clk;
input          rst_n;
input          bus_cmd_valid;
input          bus_op;
input  [15:0]  bus_addr;
input  [15:0]  bus_wr_data;
output [15:0]  bus_rd_data;
input  [7:0]   rxd;
input          rx_dv;
output [7:0]   txd;
output         tx_en;

reg[7:0] txd; reg tx_en;
reg invert;

always @(posedge clk) begin
   if(!rst_n) begin
      txd <= 8'b0;
      tx_en <= 1'b0;
   end
   else if(invert) begin
      txd <= ~rxd;
      tx_en <= rx_dv;
   end
   else begin
      txd <= rxd;
      tx_en <= rx_dv;
   end
end

always @(posedge clk) begin
   if(!rst_n)
      invert <= 1'b0;
   else if(bus_cmd_valid && bus_op) begin
      case(bus_addr)
         16'h9: begin
            invert <= bus_wr_data[0];
         end
         default: begin
         end
      endcase
   end
end

reg [15:0]  bus_rd_data;
always @(posedge clk) begin
   if(!rst_n)
      bus_rd_data <= 16'b0;
   else if(bus_cmd_valid && !bus_op) begin
      case(bus_addr)
         16'h9: begin
            bus_rd_data <= {15'b0, invert};
         end
         default: begin
            bus_rd_data <= 16'b0;
         end
      endcase
   end
end

endmodule : dut

// --------------------------------------------------------------------------------
//  SimpleBus_If
// --------------------------------------------------------------------------------
interface SimpleBus_If(input clk, input rst_n);

    logic        bus_cmd_valid;
    logic        bus_op;
    logic [15:0] bus_addr;
    logic [15:0] bus_wr_data;
    logic [15:0] bus_rd_data;
    logic [7:0]  rxd;
    logic        rx_dv;
    logic [7:0]  txd;
    logic        tx_en;

    clocking cb_bus @(posedge clk);
        output bus_cmd_valid;
        output bus_op;
        output bus_wr_data;
        input  bus_rd_data;
    endclocking

    clocking cb_dut_input @(posedge clk);
        output rxd;
        output rx_dv;
    endclocking

    clocking cb_dut_output @(posedge clk);
        input txd;
        input tx_en;
    endclocking

    modport bus_if(clocking cb_bus, input rst_n);
    modport dut_input(clocking cb_dut_input, input rst_n);
    modport dut_output(clocking cb_dut_output, input rst_n);
endinterface : SimpleBus_If

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Transaction
// --------------------------------------------------------------------------------

typedef enum {BUS_RD = 0, BUS_WR} bus_op_e;

class SimpleBus_Bus_Transaction extends uvm_sequence_item;
    `uvm_object_utils(SimpleBus_Bus_Transaction)

    rand logic [15:0] bus_addr;
    rand logic [15:0] bus_wr_data;
    rand logic [15:0] bus_rd_data;
    rand bus_op_e     bus_op;

    function new(string name = "SimpleBus_Bus_Transaction");
        super.new(name);
    endfunction
endclass : SimpleBus_Bus_Transaction

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Transaction
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Transaction extends uvm_sequence_item;
    `uvm_object_utils(SimpleBus_Dut_Transaction)

    rand logic [7:0]  pload[];
    rand logic [31:0] crc;
    rand logic [7:0]  lba;
    rand logic [7:0]  ecc;

    constraint pload_num {
        pload.size >= 64;
        pload.size <= 512;
    }

    function new(string name = "SimpleBus_Dut_Transaction ");
        super.new(name);
    endfunction
endclass : SimpleBus_Dut_Transaction

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
        for (int i = 0; i < 10; i++) begin
            bus_tr = SimpleBus_Bus_Transaction::type_id::create("bus_tr");
            start_item(bus_tr);
            assert (bus_tr.randomize())
            else begin
                `uvm_fatal("Bus Sequence", "Failed to randomize SimpleBus_Bus_Transaction")
            end
            finish_item(bus_tr);
        end
    endtask
endclass : SimpleBus_Bus_Sequence

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
        for (int i = 0; i < 10; i++) begin
            dut_tr = SimpleBus_Dut_Transaction::type_id::create("dut_dri_tr");
            start_item(dut_tr);
            assert (dut_tr.randomize())
            else begin
                `uvm_fatal("Dut Sequence", "Failed to randomize SimpleBus_Dut_Transaction")
            end
            finish_item(dut_tr);
        end
    endtask
endclass : SimpleBus_Dut_Sequence

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Sequencer
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Sequencer extends uvm_sequencer #(SimpleBus_Bus_Transaction);
    `uvm_component_utils(SimpleBus_Bus_Sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : SimpleBus_Bus_Sequencer

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Sequencer
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Sequencer extends uvm_sequencer #(SimpleBus_Dut_Transaction);
    `uvm_component_utils(SimpleBus_Dut_Sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : SimpleBus_Dut_Sequencer

// --------------------------------------------------------------------------------
//  SimpleBus_Vir_Base_Sequence
// --------------------------------------------------------------------------------
class SimpleBus_Base_Vseq extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(SimpleBus_Base_Vseq)

    SimpleBus_Bus_Sequencer bus_sqr_h;
    SimpleBus_Dut_Sequencer dut_sqr_h;

    function new(string name = "base_vseq");
        super.new(name);
    endfunction
endclass : SimpleBus_Base_Vseq

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Dut_Vseq
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Dut_Vseq extends SimpleBus_Base_Vseq;
    `uvm_object_utils(SimpleBus_Bus_Dut_Vseq)

    SimpleBus_Bus_Sequence bus_seq;
    SimpleBus_Dut_Sequence dut_seq;

    function new(string name = "bus_dut_vseq");
        super.new(name);
    endfunction

    task body();
        bus_seq = SimpleBus_Bus_Sequence::type_id::create("bus_seq");
        dut_seq = SimpleBus_Dut_Sequence::type_id::create("dut_seq");

        fork
            bus_seq.start(bus_sqr_h);
            dut_seq.start(dut_sqr_h);
        join
    endtask
endclass : SimpleBus_Bus_Dut_Vseq

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Driver
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Driver extends uvm_driver #(SimpleBus_Bus_Transaction);
    `uvm_component_utils(SimpleBus_Bus_Driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass : SimpleBus_Bus_Driver

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Driver
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Driver extends uvm_driver #(SimpleBus_Dut_Transaction);
    `uvm_component_utils(SimpleBus_Dut_Driver)

    virtual SimpleBus_If.dut_input dut_dri_vif;
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

        repeat(3) @(dut_dri_vif.cb_dut_input);
        while (packed_data.size()) begin
            @(dut_dri_vif.cb_dut_input);
            dut_dri_vif.cb_dut_input.rx_dv <= 1'b1;
            dut_dri_vif.cb_dut_input.rxd <= packed_data.pop_front();
        end

        @(dut_dri_vif.cb_dut_input);
        dut_dri_vif.cb_dut_input.rx_dv <= 1'b0;
    endtask

    function void build_phase(uvm_phase phase);
        assert (uvm_config_db #(virtual SimpleBus_If.dut_input)::get(this, "", "dut_dri_vif", dut_dri_vif))
        else begin
            `uvm_fatal("Dut Driver", "Failed to get SimpleBus_If");
        end
    endfunction 

    task run_phase(uvm_phase phase);
        dut_dri_vif.cb_dut_input.rx_dv <= 1'b0;
        dut_dri_vif.cb_dut_input.rxd   <= 8'b0;

        while (!dut_dri_vif.rst_n)
            @(dut_dri_vif.cb_dut_input);

        while (1) begin
            seq_item_port.get_next_item(dut_dri_tr);
            drive_one_block(dut_dri_tr);
            seq_item_port.item_done();
        end
    endtask
endclass : SimpleBus_Dut_Driver

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Monitor
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Monitor extends uvm_monitor;
    `uvm_component_utils(SimpleBus_Bus_Monitor)
    
    uvm_analysis_port #(SimpleBus_Bus_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        ap = new("bus_mon_ap", this);
    endfunction

endclass : SimpleBus_Bus_Monitor

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Monitor
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Monitor extends uvm_monitor;
    `uvm_component_utils(SimpleBus_Dut_Monitor)

    virtual SimpleBus_If.dut_output dut_mon_vif;
    uvm_analysis_port #(SimpleBus_Dut_Transaction) ap;
    SimpleBus_Dut_Transaction dut_mon_tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task collect_one_block(SimpleBus_Dut_Transaction dut_mon_tr);
        logic [7:0] packed_data[$];
        int i;

        while (dut_mon_vif.cb_dut_output.tx_en) begin
            packed_data.push_front(dut_mon_vif.cb_dut_output.txd);
            @(dut_mon_vif.cb_dut_output);
        end

        dut_mon_tr.pload = new[packed_data.size() - 3];
        for (i = 0; i < packed_data.size() - 3; i++)
            dut_mon_tr.pload[i] = packed_data.pop_front;

        dut_mon_tr.crc = packed_data.pop_front;
        dut_mon_tr.lba = packed_data.pop_front;
        dut_mon_tr.ecc = packed_data.pop_front;
    endtask

    function void build_phase(uvm_phase phase);
        assert (uvm_config_db #(virtual SimpleBus_If.dut_output)::get(this, "", "dut_mon_vif", dut_mon_vif))
        else begin
            `uvm_fatal("Dut Monitor", "Failed to get SimpleBus_If");
        end

        ap = new("dut_mon_ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        while (1) begin
            dut_mon_tr = SimpleBus_Dut_Transaction::type_id::create("dut_mon_tr");
            collect_one_block(dut_mon_tr);
            ap.write(dut_mon_tr);
        end
    endtask
endclass : SimpleBus_Dut_Monitor

// --------------------------------------------------------------------------------
// SimpleBus_Bus_Agent
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Agent extends uvm_agent;
    `uvm_component_utils(SimpleBus_Bus_Agent)

    SimpleBus_Bus_Monitor   bus_mon_h;
    SimpleBus_Bus_Driver    bus_dri_h;
    SimpleBus_Bus_Sequencer bus_sqr_h;
    uvm_analysis_port #(SimpleBus_Bus_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            bus_dri_h = SimpleBus_Bus_Driver::type_id::create("bus_dri", this);
            bus_sqr_h = SimpleBus_Bus_Sequencer::type_id::create("bus_sqr", this);
        end

        bus_mon_h = SimpleBus_Bus_Monitor::type_id::create("bus_mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            bus_dri_h.seq_item_port.connect(bus_sqr_h.seq_item_export);
        end

        ap = bus_mon_h.ap;
    endfunction
endclass : SimpleBus_Bus_Agent

// --------------------------------------------------------------------------------
// SimpleBus_Dut_Agent
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Agent extends uvm_agent;
    `uvm_component_utils(SimpleBus_Dut_Agent)

    SimpleBus_Dut_Monitor   dut_mon_h;
    SimpleBus_Dut_Driver    dut_dri_h;
    SimpleBus_Dut_Sequencer dut_sqr_h;
    uvm_analysis_port #(SimpleBus_Dut_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            dut_dri_h = SimpleBus_Dut_Driver::type_id::create("dut_dri", this);
            dut_sqr_h = SimpleBus_Dut_Sequencer::type_id::create("dut_sqr", this);
        end

        dut_mon_h = SimpleBus_Dut_Monitor::type_id::create("dut_mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            dut_dri_h.seq_item_port.connect(dut_sqr_h.seq_item_export);
        end

        ap = dut_mon_h.ap;
    endfunction
endclass : SimpleBus_Dut_Agent

class SimpleBus_Env extends uvm_env;
    `uvm_component_utils(SimpleBus_Env)

    SimpleBus_Bus_Agent bus_agent_h;
    SimpleBus_Dut_Agent dut_agent_h_i;
    SimpleBus_Dut_Agent dut_agent_h_o;

    // other modules

    uvm_tlm_analysis_fifo #(SimpleBus_Dut_Transaction) agt_scb_i_fifo;
    uvm_tlm_analysis_fifo #(SimpleBus_Dut_Transaction) agt_scb_o_fifo;
    //uvm_tlm_analysis_fifo #(SimpleBus_Dut_Transaction) agt_mdl_fifo;
    //uvm_tlm_analysis_fifo #(SimpleBus_Dut_Transaction) mdl_scb_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        bus_agent_h    = SimpleBus_Bus_Agent::type_id::create("bus_agent", this);
        dut_agent_h_i  = SimpleBus_Dut_Agent::type_id::create("dut_agent_i", this);
        dut_agent_h_o  = SimpleBus_Dut_Agent::type_id::create("dut_agent_o", this);
        agt_scb_i_fifo = new("agt_scb_i_fifo", this); 
        agt_scb_o_fifo = new("agt_scb_o_fifo", this); 
        //agt_mdl_fifo = new("agt_scb_fifo", this);
        //mdl_scb_fifo = new("mdl_scb_fifo", this); 
        bus_agent_h.is_active = 1;
        dut_agent_h_i.is_active = 1;
        dut_agent_h_o.is_active = 0;
    endfunction

    function void connect_phase(uvm_phase phase);
        dut_agent_h_i.ap.connect(agt_scb_i_fifo.blocking_get_export);
        dut_agent_h_o.ap.connect(agt_scb_o_fifo.blocking_get_export);
    endfunction 
endclass : SimpleBus_Env


/*
// --------------------------------------------------------------------------------
//  SimpleBus_Reg
// --------------------------------------------------------------------------------
class SimpleBus_Reg extends uvm_reg
endclass : SimpleBus_Reg

// --------------------------------------------------------------------------------
// SimpleBus_Reg_Block
// --------------------------------------------------------------------------------
class SimpleBus_Reg_Block extends uvm_reg_block;
endclass : SimpleBus_Reg
*/

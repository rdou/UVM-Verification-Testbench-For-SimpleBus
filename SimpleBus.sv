import uvm_pkg::*;
`include "uvm_macros.svh"
`timescale 1ns/10ps

typedef enum {BUS_RD = 0, BUS_WR} bus_op_e;

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

    clocking cb_bus_input @(posedge clk);
        output bus_cmd_valid;
        output bus_op;
        output bus_addr;
        output bus_wr_data;
    endclocking

    clocking cb_bus_output @(posedge clk);
        input bus_cmd_valid;
        input bus_op;
        input bus_addr;
        input bus_wr_data;
        input bus_rd_data;
    endclocking

    clocking cb_dut_input_dri @(posedge clk);
        output rxd;
        output rx_dv;
    endclocking

    clocking cb_dut_input_mon @(posedge clk);
        input rxd;
        input rx_dv;
    endclocking

    clocking cb_dut_output_mon @(posedge clk);
        input  txd;
        input  tx_en;
    endclocking

    modport bus_input(clocking cb_bus_input, input rst_n);
    modport bus_output(clocking cb_bus_output, input rst_n);
    modport dut_input_dri(clocking cb_dut_input_dri, input rst_n);
    modport dut_input_mon(clocking cb_dut_input_mon, input rst_n);
    modport dut_output_mon(clocking cb_dut_output_mon, input rst_n);

endinterface : SimpleBus_If

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
//  TOP Module
// --------------------------------------------------------------------------------
module top;
    reg clk;
    reg rst_n;

    SimpleBus_If bus_dut_if(clk, rst_n);

    initial begin

        // Interface connect testbench and dut
        uvm_config_db #(virtual SimpleBus_If.dut_input_dri)::set(null, "uvm_test_top.env.dut_agent_h_i.dut_dri_h", "dut_input_dri_vif", bus_dut_if.dut_input_dri);
        uvm_config_db #(virtual SimpleBus_If.dut_input_mon)::set(null, "uvm_test_top.env.dut_agent_h_i.dut_mon_i_h", "dut_input_mon_vif", bus_dut_if.dut_input_mon);
        uvm_config_db #(virtual SimpleBus_If.dut_output_mon)::set(null, "uvm_test_top.env.dut_agent_h_o.dut_mon_o_h", "dut_output_mon_vif", bus_dut_if.dut_output_mon);

        // Interface connect testbench and bus
        uvm_config_db #(virtual SimpleBus_If.bus_input)::set(null, "uvm_test_top.env.bus_agent_h.bus_dri_h", "bus_input_dri_vif", bus_dut_if.bus_input);
        uvm_config_db #(virtual SimpleBus_If.bus_output)::set(null, "uvm_test_top.env.bus_agent_h.bus_mon_h", "bus_output_mon_vif", bus_dut_if.bus_output);
        
        run_test("SimpleBus_Test");
    end

    dut test_dut (
                  .clk           (clk),
                  .rst_n         (rst_n),
                  .bus_cmd_valid (bus_dut_if.bus_cmd_valid),
                  .bus_op        (bus_dut_if.bus_op),
                  .bus_addr      (bus_dut_if.bus_addr),
                  .bus_wr_data   (bus_dut_if.bus_wr_data),
                  .bus_rd_data   (bus_dut_if.bus_rd_data),
                  .rxd           (bus_dut_if.rxd),
                  .rx_dv         (bus_dut_if.rx_dv),
                  .txd           (bus_dut_if.txd),
                  .tx_en         (bus_dut_if.tx_en));

    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst_n = 1'b0;
        #100
        rst_n = 1'b1;
    end
endmodule : top

// --------------------------------------------------------------------------------
// BUS START...
// --------------------------------------------------------------------------------

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
//  SimpleBus_Bus_Sequencer
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Sequencer extends uvm_sequencer #(SimpleBus_Bus_Transaction);
    `uvm_component_utils(SimpleBus_Bus_Sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : SimpleBus_Bus_Sequencer

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Driver
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Driver extends uvm_driver #(SimpleBus_Bus_Transaction);
    `uvm_component_utils(SimpleBus_Bus_Driver)

    virtual SimpleBus_If.bus_input bus_dri_vif;
    SimpleBus_Bus_Transaction bus_dri_tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        assert(uvm_config_db #(virtual SimpleBus_If.bus_input)::get(this, "", "bus_input_dri_vif", bus_dri_vif))
        else begin
            `uvm_fatal("Bus Driver", "Failed to get SimpleBus_If");
        end
    endfunction

    task drive_one_block(SimpleBus_Bus_Transaction bus_dri_tr);
        @bus_dri_vif.cb_bus_input;
        bus_dri_vif.cb_bus_input.bus_cmd_valid <= 1'b1;
        bus_dri_vif.cb_bus_input.bus_op <= (bus_dri_tr.bus_op == BUS_RD ? 0 : 1);
        bus_dri_vif.cb_bus_input.bus_addr <= bus_dri_tr.bus_addr;
        bus_dri_vif.cb_bus_input.bus_wr_data <= bus_dri_tr.bus_wr_data;

        @bus_dri_vif.cb_bus_input;
        bus_dri_vif.cb_bus_input.bus_cmd_valid <= 1'b0;
        bus_dri_vif.cb_bus_input.bus_op <= 1'b0;
        bus_dri_vif.cb_bus_input.bus_addr <= 16'b0;
        bus_dri_vif.cb_bus_input.bus_wr_data <= 16'b0;
    endtask

    task run_phase(uvm_phase phase);
        bus_dri_vif.cb_bus_input.bus_cmd_valid <= 1'b0;
        bus_dri_vif.cb_bus_input.bus_op <= 1'b0;
        bus_dri_vif.cb_bus_input.bus_addr <= 16'b0;
        bus_dri_vif.cb_bus_input.bus_wr_data <= 16'b0;

        while (!bus_dri_vif.rst_n)
            @(bus_dri_vif.cb_bus_input);

        while (1) begin
            seq_item_port.get_next_item(bus_dri_tr);
            drive_one_block(bus_dri_tr);
            seq_item_port.item_done();
        end
    endtask
endclass : SimpleBus_Bus_Driver

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Monitor
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Monitor extends uvm_monitor;
    `uvm_component_utils(SimpleBus_Bus_Monitor)

    virtual SimpleBus_If.bus_output bus_mon_vif;
    SimpleBus_Bus_Transaction bus_mon_tr;
    uvm_analysis_port #(SimpleBus_Bus_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        assert(uvm_config_db #(virtual SimpleBus_If.bus_output)::get(this, "", "bus_output_mon_vif", bus_mon_vif))
        else begin
            `uvm_fatal("Bus Monitor", "Failed to get SimpleBus_If");
        end
        ap = new("bus_mon_ap", this);
    endfunction

    task collect_one_block(SimpleBus_Bus_Transaction bus_mon_tr);
        while (1) begin
            @(bus_mon_vif.cb_bus_output);
            if (bus_mon_vif.cb_bus_output.bus_cmd_valid == 1'b1) begin
                break;
            end
        end

        bus_mon_tr.bus_op = bus_mon_vif.cb_bus_output.bus_op;
        bus_mon_tr.bus_wr_data = bus_mon_vif.cb_bus_output.bus_wr_data;
        bus_mon_tr.bus_addr = bus_mon_vif.cb_bus_output.bus_addr;

        @(bus_mon_vif.cb_bus_output);
        bus_mon_tr.bus_rd_data = bus_mon_vif.cb_bus_output.bus_rd_data;
    endtask

    task run_phase(uvm_phase phase);
        while (1) begin
            bus_mon_tr = SimpleBus_Bus_Transaction::type_id::create("bus_mon_tr");
            collect_one_block(bus_mon_tr);
            ap.write(bus_mon_tr);
        end
    endtask
endclass : SimpleBus_Bus_Monitor

// --------------------------------------------------------------------------------
// SimpleBus_Bus_Agent
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Agent extends uvm_agent;
    `uvm_component_utils(SimpleBus_Bus_Agent)

    SimpleBus_Bus_Driver    bus_dri_h;
    SimpleBus_Bus_Monitor   bus_mon_h;
    SimpleBus_Bus_Sequencer bus_sqr_h;
    uvm_analysis_port #(SimpleBus_Bus_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            bus_dri_h = SimpleBus_Bus_Driver::type_id::create("bus_dri_h", this);
            bus_sqr_h = SimpleBus_Bus_Sequencer::type_id::create("bus_sqr_h", this);
        end
        
        //`uvm_info("BUS AGENT", "Build BUS Monitor", UVM_LOW)
        bus_mon_h = SimpleBus_Bus_Monitor::type_id::create("bus_mon_h", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            bus_dri_h.seq_item_port.connect(bus_sqr_h.seq_item_export);
        end

        ap = bus_mon_h.ap;
    endfunction
endclass : SimpleBus_Bus_Agent

// --------------------------------------------------------------------------------
// DUT START...
// --------------------------------------------------------------------------------

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
//  SimpleBus_Dut_Sequencer
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Sequencer extends uvm_sequencer #(SimpleBus_Dut_Transaction);
    `uvm_component_utils(SimpleBus_Dut_Sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : SimpleBus_Dut_Sequencer

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
            dut_dri_vif.cb_dut_input_dri.rxd <= packed_data.pop_front();
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

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Base_Monitor
// --------------------------------------------------------------------------------
virtual class SimpleBus_Dut_Base_Monitor extends uvm_monitor;
    //`uvm_component_utils(SimpleBus_Dut_Base_Monitor)

    uvm_analysis_port #(SimpleBus_Dut_Transaction) ap;
    SimpleBus_Dut_Transaction dut_mon_tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task pack_tr(SimpleBus_Dut_Transaction dut_mon_tr, logic [7 : 0] packed_data[$]);
        int i; 

        dut_mon_tr.pload = new[packed_data.size() - 3];
        for (i = 0; i < packed_data.size() - 3; i++)
            dut_mon_tr.pload[i] = packed_data.pop_front;

        dut_mon_tr.crc = packed_data.pop_front;
        dut_mon_tr.lba = packed_data.pop_front;
        dut_mon_tr.ecc = packed_data.pop_front;
    endtask

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
                `uvm_info("INPUT MONITOR", "Start receiving...", UVM_LOW)
                break;
            end
        end

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

    // virtual task run_phase(uvm_phase phase);
    //     while (1) begin
    //         dut_mon_tr = SimpleBus_Dut_Transaction::type_id::create("dut_mon_tr");
    //         collect_one_block(dut_mon_tr);
    //         ap.write(dut_mon_tr);
    //     end
    // endtask
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
                `uvm_info("OUTPUT MONITOR", "Start receiving...", UVM_LOW)
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

    // virtual task run_phase(uvm_phase phase);
    //     while (1) begin
    //         dut_mon_tr = SimpleBus_Dut_Transaction::type_id::create("dut_mon_tr");
    //         collect_one_block(dut_mon_tr);
    //         ap.write(dut_mon_tr);
    //     end
    // endtask
endclass : SimpleBus_Dut_Output_Monitor

// --------------------------------------------------------------------------------
// SimpleBus_Dut_Agent
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Agent extends uvm_agent;
    `uvm_component_utils(SimpleBus_Dut_Agent)

    SimpleBus_Dut_Input_Monitor   dut_mon_i_h;
    SimpleBus_Dut_Output_Monitor   dut_mon_o_h;
    SimpleBus_Dut_Driver    dut_dri_h;
    SimpleBus_Dut_Sequencer dut_sqr_h;
    uvm_analysis_port #(SimpleBus_Dut_Transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            dut_dri_h = SimpleBus_Dut_Driver::type_id::create("dut_dri_h", this);
            dut_mon_i_h = SimpleBus_Dut_Input_Monitor::type_id::create("dut_mon_i_h", this);
            dut_sqr_h = SimpleBus_Dut_Sequencer::type_id::create("dut_sqr_h", this);
        end else begin
            dut_mon_o_h = SimpleBus_Dut_Output_Monitor::type_id::create("dut_mon_o_h", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            dut_dri_h.seq_item_port.connect(dut_sqr_h.seq_item_export);
            ap = dut_mon_i_h.ap;
        end else begin
            ap = dut_mon_o_h.ap;
        end
    endfunction
endclass : SimpleBus_Dut_Agent

// --------------------------------------------------------------------------------
//  Both DUT and BUS...
// --------------------------------------------------------------------------------

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
// SimpleBus_Scoreboard
// --------------------------------------------------------------------------------
class SimpleBus_Scoreboard extends uvm_scoreboard;
    `uvm_component_utils(SimpleBus_Scoreboard)

    uvm_blocking_get_port #(SimpleBus_Dut_Transaction) exp_port;
    uvm_blocking_get_port #(SimpleBus_Dut_Transaction) act_port;
    SimpleBus_Dut_Transaction exp_tr;
    SimpleBus_Dut_Transaction act_tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        exp_port = new("exp_port", this);
        act_port = new("rec_port", this);
    endfunction

    task run_phase(uvm_phase phase);
        while (1) begin
        end
    endtask
endclass : SimpleBus_Scoreboard

// --------------------------------------------------------------------------------
// SimpleBus_Env
// --------------------------------------------------------------------------------
class SimpleBus_Env extends uvm_env;
    `uvm_component_utils(SimpleBus_Env)

    SimpleBus_Bus_Agent bus_agent_h;
    SimpleBus_Dut_Agent dut_agent_h_i;
    SimpleBus_Dut_Agent dut_agent_h_o;
    SimpleBus_Scoreboard scb;

    uvm_tlm_analysis_fifo #(SimpleBus_Dut_Transaction) agt_scb_i_fifo;
    uvm_tlm_analysis_fifo #(SimpleBus_Dut_Transaction) agt_scb_o_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        bus_agent_h    = SimpleBus_Bus_Agent::type_id::create("bus_agent_h", this);
        dut_agent_h_i  = SimpleBus_Dut_Agent::type_id::create("dut_agent_h_i", this);
        dut_agent_h_o  = SimpleBus_Dut_Agent::type_id::create("dut_agent_h_o", this);
        scb = SimpleBus_Scoreboard::type_id::create("scb", this);
        agt_scb_i_fifo = new("agt_scb_i_fifo", this);
        agt_scb_o_fifo = new("agt_scb_o_fifo", this);
        bus_agent_h.is_active = UVM_ACTIVE;
        dut_agent_h_i.is_active = UVM_ACTIVE;
        dut_agent_h_o.is_active = UVM_PASSIVE;
    endfunction

    function void connect_phase(uvm_phase phase);
        dut_agent_h_i.ap.connect(agt_scb_i_fifo.analysis_export);
        dut_agent_h_o.ap.connect(agt_scb_o_fifo.analysis_export);
        scb.exp_port.connect(agt_scb_o_fifo.blocking_get_export);
        scb.act_port.connect(agt_scb_i_fifo.blocking_get_export);
    endfunction
endclass : SimpleBus_Env

// --------------------------------------------------------------------------------
// SimpleBus_Test
// --------------------------------------------------------------------------------
class SimpleBus_Test extends uvm_test;
    `uvm_component_utils(SimpleBus_Test)

    SimpleBus_Env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        env = SimpleBus_Env::type_id::create("env", this);
    endfunction

    task vseq_init(SimpleBus_Bus_Dut_Vseq bus_dut_vseq);
            bus_dut_vseq.bus_sqr_h = env.bus_agent_h.bus_sqr_h;
            bus_dut_vseq.dut_sqr_h = env.dut_agent_h_i.dut_sqr_h;
    endtask

    task run_phse(uvm_phase phase);
        SimpleBus_Bus_Dut_Vseq bus_dut_vseq = SimpleBus_Bus_Dut_Vseq::type_id::create("bus_dut_vseq");
        phase.raise_objection(this);
            vseq_init(bus_dut_vseq);
            bus_dut_vseq.start(null);
        phase.drop_objection(this);
    endtask
endclass : SimpleBus_Test

/* Not allowed to do this*/
//do {
//    @(bus_mon_vif.cb_bus);
//} while (bus_mon_vif.bus_cmd_valid != 1'b1);

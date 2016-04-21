// --------------------------------------------------------------------------------
// DUT
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

reg[7:0] txd;
reg tx_en;
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

    logic           bus_cmd_valid;
    logic           bus_op;
    logic [15:0] bus_addr;
    logic [15:0] bus_wr_data;
    logic [15:0] bus_rd_data;
    logic [7:0]  rxd;
    logic        rx_dv;
    logic [7:0]  txd;
    logic        tx_en;

    clocking cb_bus @(posedge clk)
        output bus_cmd_valid;
        output bus_op;
        output bus_wr_data;
        input   bus_rd_data;
    endclocking

    clocking cb_dut_input @(posedge clk)
        output rxd;
        output rx_dv;
    endclocking

    clocking cb_dut_output @(posedge clk)
        input  txd;
        input  tx_en;
    endclocking

    modport bus_if(clocking cb_bus, output rst_n);
    modport dut_input(clocking cb_dut_input, output rst_n);
    modport dut_output(clocking cb_dut_output, output rst_n);
endinterface : SimpleBus_If

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Transaction
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Transaction extends uvm_sequence_item;
    `uvm_object_utils(SimpleBus_Bus_Transaction)

    rand logic           bus_cmd_valid;
    rand logic           bus_op;
    rand logic [15:0] bus_addr;
    rand logic [15:0] bus_wr_data;

    function new(String name = "SimpleBus_Bus_Transaction")
        super.new(name);
    endfunction
endclass : SimpleBus_Bus_Transaction

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Transaction
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Transaction extends uvm_sequence_item;
    `uvm_object_utils(SimpleBus_Dut_Transaction )

    rand logic [7:0]  rxd;
    rand logic          rx_dv;

    function new(String name = "SimpleBus_Dut_Transaction ")
        super.new(name);
    endfunction
endclass : SimpleBus_Dut_Transaction

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Sequence
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Sequence extends uvm_sequence #(SimpleBus_Bus_Transaction)
    `uvm_object_utils(SimpleBus_Bus_Sequence )
    SimpleBus_Bus_Transaction tr;

    function new(String name)
        super.new(name);
    endfunction

    task body()
        for (int i = 0; i < 10; i++) begin
            tr = SimpleBus_Bus_Transaction::type_id::create("SimpleBus_Bus_Transaction");
            start_item(tr);
            assert(tr.randomize())
            else begin
                `uvm_fatal("SimpleBus_Bus_Transaction Randomization Failed")
            end
            finish_item(tr);
        end
    endtask
endclass : SimpleBus_Bus_Sequence  

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Sequence
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Sequence extends uvm_sequence #(SimpleBus_Dut_Transaction)
    `uvm_object_utils(SimpleBus_Dut_Sequence )
    SimpleBus_Dut_Transaction tr;

    function new(String name)
        super.new(name);
    endfunction

    task body()
        for (int i = 0; i < 10; i++) begin
            tr = SimpleBus_Dut_Transaction::type_id::create("SimpleBus_Dut_Transaction");
            start_item(tr);
            assert(tr.randomize())
            else begin
                `uvm_fatal("SimpleBus_Dut_Transaction Randomization Failed")
            end
            finish_item(tr);
        end
    endtask
endclass : SimpleBus_Dut_Sequence  

// --------------------------------------------------------------------------------
//  SimpleBus_Bus_Sequencer
// --------------------------------------------------------------------------------
class SimpleBus_Bus_Sequencer extends uvm_sequencer #(SimpleBus_Bus_Transaction)
    `uvm_component_utils(SimpleBus_Bus_Sequencer)

    function new(String name, uvm_component parent)
        super.new(name, parent);
    endfunction
endclass : SimpleBus_Bus_Sequencer   

// --------------------------------------------------------------------------------
//  SimpleBus_Dut_Sequencer
// --------------------------------------------------------------------------------
class SimpleBus_Dut_Sequencer extends uvm_sequencer #(SimpleBus_Dut_Transaction)
    `uvm_component_utils(SimpleBus_Dut_Sequencer)

    function new(String name, uvm_component parent)
        super.new(name, parent);
    endfunction
endclass : SimpleBus_Dut_Sequencer 













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

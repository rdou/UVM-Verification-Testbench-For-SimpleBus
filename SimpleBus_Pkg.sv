package SimpleBus_Pkg;
import uvm_pkg::*;

typedef enum {BUS_WR = 0, BUS_RD} bus_op_e;

`include "uvm_macros.svh"
`include "SimpleBus_reg_invert.svh"
`include "SimpleBus_reg_model.svh"
`include "SimpleBus_reg_seq.svh"
`include "SimpleBus_Bus_Transaction.svh"
`include "SimpleBus_Bus_Adapter.svh"
`include "SimpleBus_reg_predictor.svh"
`include "SimpleBus_Bus_Sequence.svh"
`include "SimpleBus_Bus_Sequencer.svh"
`include "SimpleBus_Bus_Driver.svh"
`include "SimpleBus_Bus_Monitor.svh"
`include "SimpleBus_Bus_Agent.svh"
`include "SimpleBus_Dut_Transaction.svh"
`include "SimpleBus_Dut_Sequence.svh"
`include "SimpleBus_Dut_Sequencer.svh"
`include "SimpleBus_Dut_Driver.svh"
`include "SimpleBus_Dut_Monitor.svh"
`include "SimpleBus_Dut_Agent.svh"
`include "SimpleBus_Vseq.svh"
`include "SimpleBus_Scoreboard.svh"
`include "SimpleBus_Env.svh"
`include "SimpleBus_Test.svh"
endpackage : SimpleBus_Pkg

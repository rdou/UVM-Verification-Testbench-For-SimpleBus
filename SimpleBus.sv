import uvm_pkg::*;
`include "uvm_macros.svh"
`timescale 1ns/10ps

typedef enum {BUS_WR = 0, BUS_RD} bus_op_e;

# How to add IVL_UVM to an existing TB

## FSM example from:
  https://github.com/shreyshakti/Activity---Simulation-based-Verification-

Used as a simple example to show how IVL_UVM can add value to simple testbenches. It is not intended as demo of full UVM capabilities.

## To add IVL_UVM to an existing TB, follow below steps:

1. Original TB is saved in orig_tb.v for reference, it is a simple linear TB, kindly review
2. Import ivl_uvm_pkg --> line: 5 in fsm_ghub_tb.sv
3. Added a simple monutor code using UVM Messaging feature, lines: 51-53 in fsm_ghub_tb.sv

## To run:

Use the Makefile provided:

  - make orig --> runs Original TB
  - make --> runs with IVL_UVM TB

## Details on IVL_UVM Integration

  - First step is to enable SV parsing in Icarus, use ** -g2012 ** flag
  - Add IVL_UVM files to your command line, done in a config file * ivl_uvm_cmds.cfg *

  Sample commands:

  - iverilog -g2012 -f ivl_uvm_cmds.cfg -o ivl_uvm.vvp
  - vvp  ivl_uvm.vvp


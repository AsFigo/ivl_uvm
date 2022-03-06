
ifeq ($(IVL_UVM_HOME),)
  export IVL_UVM_HOME=../..
endif

IVL_UVM_OPTS = -c $(IVL_UVM_HOME)/scripts/ivl_uvm_cmds.f

IVL_UVM_CMD = iverilog $(IVL_UVM_OPTS)  -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I$(IVL_UVM_HOME)/ivl_uvm_src -o vw_ivl_ivl_uvm.vvp 

all: fsm_ghub

orig: clean
	iverilog -g2012 fsm_ghub.v orig_tb.v 	
	vvp a.out

fsm_ghub: clean
	iverilog -g2012 -f ivl_uvm_cmds.cfg -o ivl_uvm.vvp 2>&1 | tee ivl_uvm_comp_fsm.log 	
	vvp -l ivl_uvm_run_fsm.log ivl_uvm.vvp


clean:
	\rm -fr  *.log  *.vvp a.out *.vcd

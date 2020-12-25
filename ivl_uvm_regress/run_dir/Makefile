
ifndef IVL_UVM_HOME
  IVL_UVM_HOME = ../../
endif

IVL_UVM_OPTS = -c $(IVL_UVM_HOME)/scripts/ivl_uvm_cmds.f

IVL_UVM_CMD = iverilog $(IVL_UVM_OPTS)  -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I$(IVL_UVM_HOME)/ivl_uvm_src -o vw_ivl_ivl_uvm.vvp 

all: vw0 vw1 vw2 vw3 vw4
vw0: clean
	$(IVL_UVM_CMD) -f flist.t0 2>&1 | tee ivl_uvm_comp_0.log 	
	vvp -l ivl_uvm_run_0.log vw_ivl_ivl_uvm.vvp
	vvp  -l ivl_uvm_run_0_HIGH.log vw_ivl_ivl_uvm.vvp +UVM_VERBOSITY=UVM_HIGH
	vvp  -l ivl_uvm_run_0_FULL.log vw_ivl_ivl_uvm.vvp +UVM_VERBOSITY=UVM_FULL

vw1: clean
	$(IVL_UVM_CMD) -f flist.t1 2>&1 | tee ivl_uvm_comp_1.log 	
	vvp -l ivl_uvm_run_1.log vw_ivl_ivl_uvm.vvp

vw2: clean
	$(IVL_UVM_CMD) -f flist.t2 2>&1 | tee ivl_uvm_comp_2.log 	
	vvp -l ivl_uvm_run_2.log vw_ivl_ivl_uvm.vvp

vw3: clean
	$(IVL_UVM_CMD) -f flist.t3 2>&1 | tee ivl_uvm_comp_3.log 	
	vvp -l ivl_uvm_run_3.log vw_ivl_ivl_uvm.vvp

vw4: clean
	$(IVL_UVM_CMD) -f flist.t4 2>&1 | tee ivl_uvm_comp_4.log 	
	vvp -l ivl_uvm_run_4.log vw_ivl_ivl_uvm.vvp


clean:
	\rm -fr  *.log  *.vvp

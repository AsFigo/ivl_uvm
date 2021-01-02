
ifeq ($(IVL_UVM_HOME),)
  export IVL_UVM_HOME=../..
endif

IVL_UVM_OPTS = -c $(IVL_UVM_HOME)/scripts/ivl_uvm_cmds.f

IVL_UVM_CMD = iverilog $(IVL_UVM_OPTS)  -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I$(IVL_UVM_HOME)/ivl_uvm_src -o vw_ivl_ivl_uvm.vvp 

all: vw0 vw1 vw2 vw3 vw4 vw5 vw6
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
	vvp -l ivl_uvm_run_3.log vw_ivl_ivl_uvm.vvp +UVM_TIMEOUT=1 

vw4: clean
	$(IVL_UVM_CMD) -f flist.t4 2>&1 | tee ivl_uvm_comp_4.log 	
	vvp -l ivl_uvm_run_4.log vw_ivl_ivl_uvm.vvp

vw5: clean
	$(IVL_UVM_CMD) -f flist.t5 2>&1 | tee ivl_uvm_comp_5.log 	
	vvp -l ivl_uvm_run_5.log vw_ivl_ivl_uvm.vvp

vw6: clean
	$(IVL_UVM_CMD) -f flist.t6 2>&1 | tee ivl_uvm_comp_6.log 	
	vvp -l ivl_uvm_run_6.log vw_ivl_ivl_uvm.vvp

vw7: clean
	$(IVL_UVM_CMD) -f flist.t7 2>&1 | tee ivl_uvm_comp_7.log 	
	vvp -l ivl_uvm_run_7.log vw_ivl_ivl_uvm.vvp


clean:
	\rm -fr  *.log  *.vvp

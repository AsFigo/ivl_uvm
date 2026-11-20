
ifeq ($(IVL_UVM_HOME),)
  export IVL_UVM_HOME=../..
endif

IVL_UVM_OPTS = -c $(IVL_UVM_HOME)/scripts/ivl_uvm_cmds.f

IVL_UVM_CMD = iverilog $(IVL_UVM_OPTS)  -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I$(IVL_UVM_HOME)/ivl_uvm_src -o vw_ivl_ivl_uvm.vvp 

AF_RUN_ARGS = +UVM_VERBOSITY=UVM_DEBUG

# Optional: space-separated test numbers for check/gold, e.g. make check TESTS="1 4" (default: all)
TESTS ?=

all: vw0 vw1 vw2 vw3 vw4 vw5 vw6 vw7 vw8 vw9 vw10 vw11
vw0: clean
	$(IVL_UVM_CMD) -f flist.t0 2>&1 | tee ivl_uvm_comp_0.log 	
	vvp -l ivl_uvm_run_0.log vw_ivl_ivl_uvm.vvp +UVM_MAX_QUIT_COUNT=10 $(AF_RUN_ARGS)
	vvp  -l ivl_uvm_run_0_HIGH.log vw_ivl_ivl_uvm.vvp +UVM_VERBOSITY=UVM_HIGH
	vvp  -l ivl_uvm_run_0_FULL.log vw_ivl_ivl_uvm.vvp +UVM_VERBOSITY=UVM_FULL

vw1: clean
	$(IVL_UVM_CMD) -f flist.t1 2>&1 | tee ivl_uvm_comp_1.log 	
	vvp -l ivl_uvm_run_1.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw2: clean
	$(IVL_UVM_CMD) -f flist.t2 2>&1 | tee ivl_uvm_comp_2.log 	
	vvp -l ivl_uvm_run_2.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw3: clean
	$(IVL_UVM_CMD) -f flist.t3 2>&1 | tee ivl_uvm_comp_3.log 	
	vvp -l ivl_uvm_run_3.log vw_ivl_ivl_uvm.vvp +UVM_TIMEOUT=1 $(AF_RUN_ARGS)

vw4: clean
	$(IVL_UVM_CMD) -f flist.t4 2>&1 | tee ivl_uvm_comp_4.log 	
	vvp -l ivl_uvm_run_4.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw5: clean
	$(IVL_UVM_CMD) -f flist.t5 2>&1 | tee ivl_uvm_comp_5.log 	
	vvp -l ivl_uvm_run_5.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw6: clean
	$(IVL_UVM_CMD) -f flist.t6 2>&1 | tee ivl_uvm_comp_6.log 	
	vvp -l ivl_uvm_run_6.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw7: clean
	$(IVL_UVM_CMD) -f flist.t7 2>&1 | tee ivl_uvm_comp_7.log 	
	vvp -l ivl_uvm_run_7.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw8: clean
	$(IVL_UVM_CMD) -s t_scope_stack -f flist.t8 2>&1 | tee ivl_uvm_comp_8.log 	
	vvp -l ivl_uvm_run_8.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw9: clean
	$(IVL_UVM_CMD) -s t_copy_map -f flist.t9 2>&1 | tee ivl_uvm_comp_9.log 	
	vvp -l ivl_uvm_run_9.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw10: clean
	$(IVL_UVM_CMD) -s t_status_container -f flist.t10 2>&1 | tee ivl_uvm_comp_10.log 	
	vvp -l ivl_uvm_run_10.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw11: clean
	$(IVL_UVM_CMD) -s t_comparer -f flist.t11 2>&1 | tee ivl_uvm_comp_11.log 	
	vvp -l ivl_uvm_run_11.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)


# Regression against golden logs (../goldLogs): make check [TESTS="1 4"], make gold to refresh
check:
	./ivl_uvm_check.sh check $(TESTS)

gold:
	./ivl_uvm_check.sh gold $(TESTS)

clean:
	\rm -fr  *.log  *.vvp

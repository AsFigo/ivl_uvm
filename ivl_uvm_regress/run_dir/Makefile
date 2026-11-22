
ifeq ($(IVL_UVM_HOME),)
  export IVL_UVM_HOME=../..
endif

IVL_UVM_OPTS = -c $(IVL_UVM_HOME)/scripts/ivl_uvm_cmds.f

IVL_UVM_CMD = iverilog $(IVL_UVM_OPTS)  -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I$(IVL_UVM_HOME)/ivl_uvm_src -o vw_ivl_ivl_uvm.vvp 

AF_RUN_ARGS = +UVM_VERBOSITY=UVM_DEBUG

# Optional: space-separated test numbers for check/gold, e.g. make check TESTS="1 4" (default: all)
TESTS ?=

all: vw0 vw1 vw2 vw3 vw4 vw5 vw6 vw7 vw8 vw9 vw10 vw11 vw12 vw13 vw14 vw15 vw16 vw17 vw18 vw19 vw20 vw21 vw22 vw23 vw24
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

vw12: clean
	$(IVL_UVM_CMD) -s t_packer -f flist.t12 2>&1 | tee ivl_uvm_comp_12.log 	
	vvp -l ivl_uvm_run_12.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw13: clean
	$(IVL_UVM_CMD) -s t_copy_clone -f flist.t13 2>&1 | tee ivl_uvm_comp_13.log 	
	vvp -l ivl_uvm_run_13.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw14: clean
	$(IVL_UVM_CMD) -s t_printer -f flist.t14 2>&1 | tee ivl_uvm_comp_14.log 	
	vvp -l ivl_uvm_run_14.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw15: clean
	$(IVL_UVM_CMD) -s t_field_macros -f flist.t15 2>&1 | tee ivl_uvm_comp_15.log 	
	vvp -l ivl_uvm_run_15.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw16: clean
	$(IVL_UVM_CMD) -s t_transaction -f flist.t16 2>&1 | tee ivl_uvm_comp_16.log 	
	vvp -l ivl_uvm_run_16.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw17: clean
	$(IVL_UVM_CMD) -s t_sequence_item -f flist.t17 2>&1 | tee ivl_uvm_comp_17.log 	
	vvp -l ivl_uvm_run_17.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw18: clean
	$(IVL_UVM_CMD) -s t_registry -f flist.t18 2>&1 | tee ivl_uvm_comp_18.log 	
	vvp -l ivl_uvm_run_18.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw19: clean
	$(IVL_UVM_CMD) -s t_item_flow -f flist.t19 2>&1 | tee ivl_uvm_comp_19.log 	
	vvp -l ivl_uvm_run_19.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)


vw20: clean
	$(IVL_UVM_CMD) -s t_component -f flist.t20 2>&1 | tee ivl_uvm_comp_20.log 	
	vvp -l ivl_uvm_run_20.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw21: clean
	$(IVL_UVM_CMD) -s t_run_test_phases -f flist.t21 2>&1 | tee ivl_uvm_comp_21.log 	
	vvp -l ivl_uvm_run_21.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw22: clean
	$(IVL_UVM_CMD) -s t_comp_registry -f flist.t22 2>&1 | tee ivl_uvm_comp_22.log 	
	vvp -l ivl_uvm_run_22.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw23: clean
	$(IVL_UVM_CMD) -s t_children_walk -f flist.t23 2>&1 | tee ivl_uvm_comp_23.log 	
	vvp -l ivl_uvm_run_23.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

vw24: clean
	$(IVL_UVM_CMD) -s t_deep_tree -f flist.t24 2>&1 | tee ivl_uvm_comp_24.log 	
	vvp -l ivl_uvm_run_24.log vw_ivl_ivl_uvm.vvp $(AF_RUN_ARGS)

# Regression against golden logs (../goldLogs): make check [TESTS="1 4"], make gold to refresh
check:
	./ivl_uvm_check.sh check $(TESTS)

gold:
	./ivl_uvm_check.sh gold $(TESTS)

clean:
	\rm -fr  *.log  *.vvp

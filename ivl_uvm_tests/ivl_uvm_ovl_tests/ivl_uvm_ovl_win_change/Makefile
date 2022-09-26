all: clean ovl_win_change_pass ovl_win_change_fail help

ovl_win_change_pass: 
	iverilog -g2012 -s test -I${IVL_UVM_HOME}/ivl_uvm_std_ovl/ -f flist ivl_uvm_ovl_win_change_pass.sv>& pass_comp.log
	vvp a.out >& pass_run.log

ovl_win_change_fail: 
	iverilog -g2012 -s test -I${IVL_UVM_HOME}/ivl_uvm_std_ovl/ -f flist ivl_uvm_ovl_win_change_fail.sv>& fail_comp.log
	vvp a.out >& fail_run.log

clean:
	rm -fr a.out *.log *.vcd tee

help:	
	@echo "(Targets -  clean pass fail ovl_fifo_index_pass ovl_fifo_index_fail ovl_even_parity_pass ovl_even_parity_fail ovl_win_change_pass ovl_win_change_fail )"
     



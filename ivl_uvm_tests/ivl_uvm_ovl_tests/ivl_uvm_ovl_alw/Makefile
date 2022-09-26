all: clean pass fail

pass: 
	iverilog -g2012 -s test -I${IVL_UVM_HOME}/ivl_uvm_std_ovl/ -f flist ivl_uvm_ovl_a_alw_pass.sv >& pass_comp.log
	#iverilog -s test -I../../ivl_uvm_std_ovl/ ../../ivl_uvm_std_ovl/ivl_uvm_ovl_inc.v ivl_uvm_ovl_ex.sv |& tee comp.log
	vvp a.out >& pass_run.log

fail: 
	iverilog -g2012 -s test -I${IVL_UVM_HOME}/ivl_uvm_std_ovl/ -f flist ivl_uvm_ovl_a_alw_fail.sv >& fail_comp.log
	vvp a.out >& fail_run.log


clean:
	rm -fr a.out *.log *.vcd tee




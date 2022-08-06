all: clean
	iverilog -s test -I${IVL_UVM_HOME}/ivl_uvm_std_ovl/ ${IVL_UVM_HOME}/ivl_uvm_std_ovl/ivl_uvm_ovl_inc.v ivl_uvm_ovl_ex.sv |& tee comp.log
	#iverilog -s test -I../../ivl_uvm_std_ovl/ ../../ivl_uvm_std_ovl/ivl_uvm_ovl_inc.v ivl_uvm_ovl_ex.sv |& tee comp.log
	vvp a.out |& tee run.log

clean:
	rm -fr a.out *.log *.vcd




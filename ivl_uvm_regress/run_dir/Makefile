vw0: clean
	iverilog -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I../../ivl_uvm_src -o vw_ivl_go2uvm.vvp  -f flist.t0 2>&1 | tee go2uvm_comp.log 	
	vvp -l go2uvm_run.log vw_ivl_go2uvm.vvp
	vvp  -l go2uvm_run_HIGH.log vw_ivl_go2uvm.vvp +UVM_VERBOSITY=UVM_HIGH
	vvp  -l go2uvm_run_FULL.log vw_ivl_go2uvm.vvp +UVM_VERBOSITY=UVM_FULL

vw1: clean
	iverilog -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I../../ivl_uvm_src -o vw_ivl_go2uvm.vvp  -f flist.t1 2>&1 | tee go2uvm_comp.log 	
	vvp -l go2uvm_run.log vw_ivl_go2uvm.vvp

vw2: clean
	iverilog -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I../../ivl_uvm_src -o vw_ivl_go2uvm.vvp  -f flist.t2 2>&1 | tee go2uvm_comp.log 	
	vvp -l go2uvm_run.log vw_ivl_go2uvm.vvp

t: clean
	iverilog -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I../../ivl_uvm_src -o vw_ivl_go2uvm.vvp  -f f.t 2>&1 | tee go2uvm_comp.log 	
	vvp -l go2uvm_run.log vw_ivl_go2uvm.vvp


clean:
	\rm -fr  *.log  *.vvp

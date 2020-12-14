vw1: clean
	iverilog -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I../ -o vw_ivl_go2uvm.vvp  -f flist.class 2>&1 | tee go2uvm_comp.log 	
	vvp -l go2uvm_run.log vw_ivl_go2uvm.vvp

clean:
	\rm -fr  *.log  *.vvp

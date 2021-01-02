
ifeq ($(IVL_UVM_HOME),)
  export IVL_UVM_HOME=../..
endif

IVL_UVM_OPTS = -c $(IVL_UVM_HOME)/scripts/ivl_uvm_cmds.f

IVL_UVM_CMD = iverilog $(IVL_UVM_OPTS)  -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 -I$(IVL_UVM_HOME)/ivl_uvm_src -o vw_ivl_ivl_uvm.vvp 

clean:
	\rm -fr  *.log  *.vvp

all: apb
apb: clean
	$(IVL_UVM_CMD) -f flist.apb 2>&1 | tee ivl_uvm_comp_apb.log 	
	vvp -l ivl_uvm_run_apb.log vw_ivl_ivl_uvm.vvp

ivl_uvm_intf_gen: clean
	iverilog-vpi -mingw=/mingw64 ../ivlog_vpi_src/az_ivl_uvm_intf_gen.c |& tee comp.log
	cp ../ivlog_vpi_src/az_ivl_uvm_intf_gen.vpi .
	iverilog -DIVL_UVM_INTF_GEN -o az_ivl_uvm_intf_gen.vvp ../examples/register_slice.v
	vvp -M. -m../ivlog_vpi_src/az_ivl_uvm_intf_gen az_ivl_uvm_intf_gen.vvp
	iverilog  -g2012 -o az_ivl_uvm.vvp ../examples/register_slice.v register_slice_if.sv register_slice_tb.sv
	vvp az_ivl_uvm.vvp

clean:
	rm -fr *.o *.so work* *.v *.sv *.o *.so *.vvp a.out *.vpi


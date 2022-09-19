ivl_lint: clean
	iverilog-vpi -mingw=/mingw64 lint_check.c check_name.c  |& tee comp.log
	iverilog  -o lint.vvp test.v
	vvp -M. -mlint_check lint.vvp |& tee run.log

clean:
	rm -fr *.o *.so work*  *.o *.so *.vvp a.out *.vpi *.log *~


Welcome to **IVL_UVM** project

It is a humble attempt to implement some of the basic UVM features on open-source Icarus Verilog simulator and eventually port it to Verilator as well. 

Given the light-weight support of SystemVerilog by Icarus as of Dec 2020, IVL_UVM code base is also very rudimentary compared to Accellera UVM implementation. We hope to continue enhancing it as and when the Icarus SV support improves.

It is very important to note that current support is very, very limited and is just a start. We have staretd with:

. Basic Messaging support
. Command Line Processor features
. UVM Test feature

Feel free to try it out and send constructive comments via Discussion forum/Issues. Any inappropriate comments shall be deleted without any notice whatsoever. 

As of now, IVL_UVM runs on latest/development build of Icarus (and NOT the stable v11.0 branch). Should you need the v11.0 support, feel free to raise a request, we will see if that is doable.

To run basic tests, do:

cd ivl_uvm_regress/run_dir/
make vw0
make vw1
make vw2

Thanks for trying this IVL_UVM code base.

Cheers

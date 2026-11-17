# Welcome to *IVL_UVM* project

IVL_UVM brings a subset of UVM to the open-source [Icarus Verilog](https://github.com/steveicarus/iverilog) simulator. You write a testbench in familiar UVM style (`uvm_info`, `uvm_component`, `uvm_test`, `run_test`, the factory) and run it with Icarus. We also plan to port it to Verilator.

It is a growing subset of UVM, not a full implementation. Icarus's SystemVerilog support is still limited, so IVL_UVM stays rudimentary compared to the Accellera UVM implementation. We continue to enhance it as the Icarus SystemVerilog support improves.

## What works today

* Messaging: `uvm_info`, `uvm_warning`, `uvm_error`, `uvm_fatal`, verbosity control and the final summary
* Command line options: `+UVM_VERBOSITY`, `+UVM_TIMEOUT`, `+UVM_MAX_QUIT_COUNT`, `+UVM_TESTNAME`
* `uvm_component` and `uvm_test` with the component phases
* Test selection at run time: `+UVM_TESTNAME=my_test` or `run_test("my_test")`, with `` `uvm_component_utils `` to register a test
* A factory: `create_component_by_name`, `create_object_by_name`, `is_type_name_registered`, `print`
* Mailbox and simple TLM-style ports
* An APB master example

**Documentation: <https://asfigo.github.io/ivl_uvm/>**

The documentation has the full feature list, including what is not available yet (`feature_status`), and the differences from standard UVM (`limitations`). The pages are written in reStructuredText for Sphinx and live in `docs/source/`.

IVL_UVM runs on the latest/development build of Icarus (and NOT the stable v11.0 branch). Should you need v11.0 support, feel free to raise a request and we will see if that is doable.

## Setup

Set up the IVL_UVM path with `setup.csh`. In csh/tcsh, from the repository root:

* `source setup.csh`

Many scripts and Makefiles refer to an environment variable set by this file.

## Run the tests

* `cd ivl_uvm_regress/run_dir`
* `make vw1` runs one test (`vw0` to `vw7` run tests `t0` to `t7`)
* `make check` runs all the tests and compares each log with its golden log in `ivl_uvm_regress/goldLogs`, printing PASS or FAIL per test
* `make check TESTS="1 4"` runs only those tests
* `make gold` refreshes the golden logs after an intended change

## A minimal test

```systemverilog
package test_pkg;
  import ivl_uvm_pkg::*;

  class my_test extends uvm_test;
    `uvm_component_utils(my_test)
    function new (string name = "my_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
  endclass : my_test
endpackage : test_pkg

module top;
  import ivl_uvm_pkg::*;
  import test_pkg::*;
  initial begin
    run_test();
    $finish;
  end
endmodule : top
```

Run it with `+UVM_TESTNAME=my_test`. `uvm_test` is abstract, as in standard UVM, so every test needs its own derived class. More on this in `docs/source/factory_and_test_selection.rst`.

## ABV support via OVL

Assertion Based Verification (ABV) is a powerful technique used by both RTL designers and verification engineers. Accellera OVL (Open Verification Library) provides a set of ready-to-use library elements with assertions for common elements and behaviors. We compiled OVL with Icarus and did some small clean-up. Further TODOs:

* Integrate UVM reporting
* Tighter control of MAX_QUIT_COUNT in a more UVM-like manner (than compile time in old OVL)
* Better debug

To run the simple OVL demo:

* `cd ivl_uvm_tests/ivl_uvm_ovl_demo/ivl_uvm_ovl_alw`
* `make`

## Feedback

Feel free to try it out and send constructive comments via the Discussion forum or Issues. Any inappropriate comments will be deleted without notice.

Thanks for trying this IVL_UVM code base.

Cheers

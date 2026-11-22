Writing Tests
=============

Rules for a test that runs on IVL_UVM today:

* Derive tests from ``uvm_test`` and components from ``uvm_component``. Both are abstract, so you
  always need your own derived class.
* Use the standard constructor ``new(string name, uvm_component parent)``.
* Register every test and component with ``uvm_component_utils(<class>)`` inside the class, and
  every object or transaction with ``uvm_object_utils(<class>)`` (or the ``*_begin`` / ``*_end``
  form with field macros).
* Put the classes in a package that imports ``ivl_uvm_pkg::*``.
* End the file list with ``ivl_uvm_top.svh`` to get the final report summary (see
  :doc:`getting_started`).
* Create components and objects with ``<class>::type_id::create``. Create child components in
  ``build_phase`` with ``this`` as the parent; they take part in all the phases that follow.
* Do not wait forever in a ``run_phase``: the ``run_phase`` tasks run one after another, so a
  component that never returns holds up the rest. See :doc:`phasing`.
* Do not use the field macros for arrays, queues or associative arrays; they are not ported yet.
* Write ``this.`` in front of calls to inherited methods inside your methods (see
  :doc:`limitations`).

A test with a child component
-----------------------------

.. code-block:: systemverilog

   package my_pkg;
     import ivl_uvm_pkg::*;

     class my_env extends uvm_component;
       `uvm_component_utils(my_env)

       function new(string name, uvm_component parent);
         super.new(name, parent);
       endfunction : new

       function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         `uvm_info("ENV", {"build in ", this.get_full_name()}, UVM_LOW)
       endfunction : build_phase
     endclass : my_env

     class my_test extends uvm_test;
       `uvm_component_utils(my_test)
       my_env env;

       function new(string name, uvm_component parent);
         super.new(name, parent);
       endfunction : new

       function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         env = my_env::type_id::create("env", this);
       endfunction : build_phase

       task run_phase(uvm_phase phase);
         phase.raise_objection(this);
         #10;
         phase.drop_objection(this);
       endtask : run_phase
     endclass : my_test
   endpackage : my_pkg

   module top;
     import ivl_uvm_pkg::*;
     import my_pkg::*;
     initial begin
       run_test("my_test");
       $finish;
     end
   endmodule : top

The ``raise_objection`` and ``drop_objection`` calls compile and run, but they do not hold the run
phase open yet (see :doc:`limitations`).

Messages
--------

.. code-block:: systemverilog

   `uvm_info("MY_ID", "hello", UVM_MEDIUM)
   `uvm_warning("MY_ID", "careful")
   `uvm_error("MY_ID", "something failed")
   `uvm_fatal("MY_ID", "cannot continue")

Run with ``+UVM_VERBOSITY=UVM_HIGH`` (or ``UVM_DEBUG``) to see more. Call ``report_summarize()``
at the end of a test to print the totals.

Example tests
-------------

The tests under ``ivl_uvm_tests/`` are small, incremental examples. They are listed on the
:doc:`regression` page. ``t21_run_test_phases`` is a good first one to read: it looks like the first
test a UVM user writes.

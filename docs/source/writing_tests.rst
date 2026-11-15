Writing Tests
=============

Rules for a test that runs on IVL_UVM today:

* Derive tests from ``uvm_test`` and components from ``uvm_component``. Both are abstract, so you
  always need your own derived class.
* Use the standard constructor ``new(string name, uvm_component parent)``.
* Register every test with ``uvm_component_utils(<class>)`` inside the class.
* Put the classes in a package that imports ``ivl_uvm_pkg::*``.
* End the file list with ``ivl_uvm_top.svh``.
* Create components with ``new`` or ``factory.create_component_by_name``.

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
:doc:`regression` page.

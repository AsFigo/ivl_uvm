Getting Started
===============

Requirements
------------

* A development build of Icarus Verilog (``iverilog`` and ``vvp`` on your ``PATH``).
* ``csh``/``tcsh`` for the setup script.

Setup
-----

From the repository root:

.. code-block:: tcsh

   source setup.csh

This sets ``IVL_UVM_HOME``, which the Makefiles and file lists use.

Run a test
----------

.. code-block:: tcsh

   cd ivl_uvm_regress/run_dir
   make vw1

``vw1`` compiles and runs test ``t1``. The log files ``ivl_uvm_comp_1.log`` (compile) and
``ivl_uvm_run_1.log`` (run) are written to the same directory. Targets ``vw0`` to ``vw7`` run
tests ``t0`` to ``t7``; see :doc:`regression`.

Run all tests and compare with the golden logs
----------------------------------------------

.. code-block:: tcsh

   make check

Compile line
------------

The Makefile compiles a test like this:

.. code-block:: tcsh

   iverilog -c $IVL_UVM_HOME/scripts/ivl_uvm_cmds.f -DVW_IVLOG_GO2UVM -DIVL_UVM -g2012 \
            -I$IVL_UVM_HOME/ivl_uvm_src -o vw_ivl_ivl_uvm.vvp -f flist.t4

A file list has three parts: the package, your test files, and ``ivl_uvm_top.svh`` as the last
entry.

.. code-block:: text

   ${IVL_UVM_HOME}/ivl_uvm_src/ivl_uvm_pkg.sv
   ../../ivl_uvm_tests/ivl_uvm_test_4/ivl_uvm_test_bcl.sv

   // This should be the last line in the file list
   ${IVL_UVM_HOME}/ivl_uvm_src/ivl_uvm_top.svh

Run-time options
----------------

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Option
     - Meaning
   * - ``+UVM_TESTNAME=<name>``
     - Test class to run (see :doc:`factory_and_test_selection`)
   * - ``+UVM_VERBOSITY=<level>``
     - Message verbosity, for example ``UVM_MEDIUM``, ``UVM_HIGH``, ``UVM_DEBUG``
   * - ``+UVM_TIMEOUT=<n>``
     - Global simulation timeout
   * - ``+UVM_MAX_QUIT_COUNT=<n>``
     - Stop after this many errors

Regression
==========

The tests live in ``ivl_uvm_tests/`` and run from ``ivl_uvm_regress/run_dir`` with
``make vw0`` to ``make vw24``.

.. list-table::
   :header-rows: 1
   :widths: 8 30 62

   * - Target
     - Test
     - What it covers
   * - ``vw0``
     - ``t0_msg_verbosity``
     - Messages at all severities and verbosities. Ends with 3 errors and a fatal on purpose.
   * - ``vw1``
     - ``t1_class_phases``
     - Component phases.
   * - ``vw2``
     - ``t2_run_test_default``
     - ``run_test`` with a default test.
   * - ``vw3``
     - ``t3_clp_timeout``
     - ``+UVM_TIMEOUT``. Ends with the timeout error on purpose.
   * - ``vw4``
     - ``ivl_uvm_test_4``
     - Test chosen through the factory with a user-defined test class.
   * - ``vw5``
     - ``t5_mbx_int``
     - Mailbox with integer payloads.
   * - ``vw6``
     - ``t6_mbx_class``
     - Mailbox with class payloads.
   * - ``vw7``
     - ``t7_apb_vip``
     - APB master example. Ends on the global timeout, which is the expected result.
   * - ``vw8``
     - ``t8_scope_stack``
     - ``uvm_scope_stack``.
   * - ``vw9``
     - ``t9_copy_map``
     - ``uvm_copy_map``.
   * - ``vw10``
     - ``t10_status_container``
     - ``uvm_status_container``.
   * - ``vw11``
     - ``t11_comparer``
     - ``uvm_comparer`` and ``compare``.
   * - ``vw12``
     - ``t12_packer``
     - ``uvm_packer``, ``pack`` and ``unpack``.
   * - ``vw13``
     - ``t13_copy_clone``
     - ``copy`` and ``clone``.
   * - ``vw14``
     - ``t14_printer``
     - The table printer, ``print`` and ``sprint``.
   * - ``vw15``
     - ``t15_field_macros``
     - The field macros for int, string, enum, real and object fields.
   * - ``vw16``
     - ``t16_transaction``
     - ``uvm_transaction``.
   * - ``vw17``
     - ``t17_sequence_item``
     - ``uvm_sequence_item``.
   * - ``vw18``
     - ``t18_registry``
     - ``type_id`` and the registry for objects.
   * - ``vw19``
     - ``t19_item_flow``
     - A user item: create with ``type_id``, print, copy, clone, compare, pack and unpack.
   * - ``vw20``
     - ``t20_component``
     - ``uvm_component``: name, parent, full name, children, depth, duplicate child name.
   * - ``vw21``
     - ``t21_run_test_phases``
     - A user-style test through ``run_test``: ``build_phase`` to ``report_phase``, an item created
       with ``type_id``, objections.
   * - ``vw22``
     - ``t22_component_registry``
     - ``type_id::create(name, parent)`` for components, ``get_type``, creation by type name.
   * - ``vw23``
     - ``t23_children_walk``
     - A test, an env and two agents: the order of the phases over the tree (see :doc:`phasing`).
   * - ``vw24``
     - ``t24_deep_tree``
     - The same on a deeper tree with branches: order, full names, depth and child counts.

Golden logs
-----------

Each test has golden logs in ``ivl_uvm_regress/goldLogs``.

.. code-block:: tcsh

   cd ivl_uvm_regress/run_dir
   make check                  # all tests: PASS or FAIL for each
   make check TESTS="1 4"      # only these tests
   make gold                   # refresh the golden logs after an intended change

``make check`` runs each test, removes file paths and line numbers from the report tags, and
compares the result with the golden log. Editing the sources does not cause false failures, but a
changed message, time stamp or severity count does.

A test passes only if all of these hold:

* ``make vwN`` succeeds. An unknown target, such as ``TESTS=99``, fails.
* The run log was produced.
* Every log the golden directory lists for the test was produced.
* Every produced log matches its golden log.

``make check`` exits with a non-zero status if any test fails. ``make gold`` writes nothing for a
test that does not meet the first two conditions, and also exits with a non-zero status.

Expected failures
-----------------

The golden logs of ``vw0`` and ``vw3`` contain the intended errors of those tests. The APB example
(``vw7``) is different: it ends on the global timeout. It is listed in
``ivl_uvm_regress/expected_fail.list``, one line per test:

.. code-block:: text

   7|Reached Timeout value of|the APB test ends at the global timeout (1 ms) with one UVM_ERROR; ...

The line gives the test number, text that must appear in the run log, and the reason. The test
passes only while that text is in its log, and the report says ``PASS (expected failure: ...)``.
If the test ever starts to complete, it fails until the line is updated or removed.

Checking the runner
-------------------

``ivl_uvm_check_selftest.sh`` tests the runner itself with a fake set of targets and needs no
simulator:

.. code-block:: tcsh

   cd ivl_uvm_regress/run_dir
   ./ivl_uvm_check_selftest.sh

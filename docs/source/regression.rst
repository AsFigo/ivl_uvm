Regression
==========

The tests live in ``ivl_uvm_tests/`` and run from ``ivl_uvm_regress/run_dir`` with
``make vw0`` to ``make vw7``.

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
     - APB master example. Currently ends on the global timeout.

Golden logs
-----------

Each test has a golden log in ``ivl_uvm_regress/goldLogs``.

.. code-block:: tcsh

   cd ivl_uvm_regress/run_dir
   make check                  # all tests: PASS or FAIL for each
   make check TESTS="1 4"      # only these tests
   make gold                   # refresh the golden logs after an intended change

``make check`` runs each test, removes file paths and line numbers from the report tags, and
compares the result with the golden log. Editing the sources does not cause false failures, but a
changed message, time stamp or severity count does. It exits with a non-zero status if any test
differs.

The golden logs also record the expected result of each test, including the intended errors of
``vw0`` and ``vw3`` and the timeout of ``vw7``.

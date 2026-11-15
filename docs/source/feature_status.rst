Feature Status
==============

Status of the UVM features in IVL_UVM. *Works* means a regression test covers it.

.. list-table::
   :header-rows: 1
   :widths: 28 14 58

   * - Feature
     - Status
     - Notes
   * - Messaging: ``uvm_info``, ``uvm_warning``, ``uvm_error``, ``uvm_fatal``
     - Works
     - Verbosity control, severity counts and the final summary. Test ``t0``.
   * - Command-line options
     - Works
     - ``+UVM_VERBOSITY``, ``+UVM_TIMEOUT``, ``+UVM_MAX_QUIT_COUNT``, ``+UVM_TESTNAME``. Tests ``t0``, ``t3``.
   * - ``uvm_component`` phases
     - Partial
     - ``build`` to ``final`` run once, in order, on the test. The ``parent`` argument is accepted but the component hierarchy is not tracked yet.
   * - ``uvm_object``
     - Partial
     - ``print``, ``create``, ``get_type_name``. Field automation macros are not available.
   * - ``run_test`` and ``+UVM_TESTNAME``
     - Works
     - Pick the test at run time. Tests ``t0`` to ``t6``.
   * - Factory
     - Partial
     - ``create_component_by_name``, ``create_object_by_name``, ``is_type_name_registered``, ``print``. No overrides yet.
   * - ``uvm_component_utils``
     - Works
     - Registers the class with the factory.
   * - ``uvm_object_utils``, ``*_begin`` / ``*_end``, field macros
     - Not yet
     - Do not compile today. Planned.
   * - ``type_id::create``, ``type_id::get``
     - Not supported
     - Use ``factory.create_component_by_name`` instead. See :doc:`limitations`.
   * - Mailbox (``ivl_uvm_mbx``)
     - Works
     - Integer and class payloads. Tests ``t5``, ``t6``.
   * - Simple TLM pull port and export
     - Partial
     - Mailbox-style ``put``/``get`` between components.
   * - APB master example
     - Partial
     - Module-based master and slave DUT, test ``t7``. Currently ends on the global timeout.
   * - ``uvm_config_db``, objections, sequences, sequencer, driver, monitor, agent, env
     - Not yet
     - Not part of IVL_UVM today.

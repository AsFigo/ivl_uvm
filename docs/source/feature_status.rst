Feature Status
==============

Status of the UVM features in IVL_UVM. *Works* means a regression test covers it; the test numbers
are listed on the :doc:`regression` page.

.. list-table::
   :header-rows: 1
   :widths: 28 14 58

   * - Feature
     - Status
     - Notes
   * - Messaging: ``uvm_info``, ``uvm_warning``, ``uvm_error``, ``uvm_fatal``
     - Works
     - Verbosity control, severity counts and the final summary. Test ``t0``. Messages do not show
       the name of the component that reports them.
   * - Command-line options
     - Works
     - ``+UVM_VERBOSITY``, ``+UVM_TIMEOUT``, ``+UVM_MAX_QUIT_COUNT``, ``+UVM_TESTNAME``. Tests ``t0``, ``t3``.
   * - ``uvm_object``
     - Works
     - ``create``, ``get_type_name``, ``print`` and ``sprint`` (table format), ``copy``, ``clone``,
       ``compare``, ``pack`` and ``unpack``. Tests ``t11`` to ``t14``. Recording is not available, and
       ``reseed`` has no effect because Icarus does not support random seeding of a class.
   * - Field automation macros
     - Partial
     - ``uvm_field_int``, ``uvm_field_string``, ``uvm_field_enum``, ``uvm_field_real`` and
       ``uvm_field_object``. Test ``t15``. The array, queue and associative-array macros are not
       ported yet; do not use them.
   * - ``uvm_transaction``, ``uvm_sequence_item``
     - Works
     - Tests ``t16``, ``t17``, ``t19``. The sequencer and sequence handles of an item are
       placeholders.
   * - ``uvm_object_utils``, ``*_begin`` / ``*_end``, ``type_id::create``, ``get_type``,
       ``get_object_type``
     - Works
     - For objects. Tests ``t18``, ``t19``.
   * - ``uvm_component``: name, parent, full name, children, depth
     - Works
     - ``get_parent``, ``get_full_name``, ``get_child``, ``get_first_child`` / ``get_next_child``,
       ``get_num_children``, ``has_child``, ``get_depth``. A duplicate child name is a fatal error.
       Test ``t20``. The children are listed newest first, not in name order.
   * - ``uvm_component_utils``, ``type_id::create(name, parent)``
     - Works
     - For components, with ``get_type`` and ``get_object_type``. Test ``t22``.
   * - ``run_test`` and ``+UVM_TESTNAME``
     - Works
     - Pick the test at run time. Tests ``t0`` to ``t6``, ``t21``.
   * - Phases ``build`` to ``final`` over the whole component tree
     - Works
     - The phases are run one after another over the test and all its children, in the order of
       standard UVM. Tests ``t21``, ``t23``, ``t24``. A component without a parent is not phased.
       See :doc:`phasing`.
   * - Parallel ``run_phase``
     - Works
     - The ``run_phase`` tasks of all components start together and run in parallel. The run phase
       ends when the objections are dropped, and the tasks still running (for example a ``forever``
       loop) are stopped. Tests ``t26``, ``t27``. See :doc:`phasing`.
   * - Objections: ``raise_objection``, ``drop_objection``, ``get_objection_total``
     - Partial
     - One total for the run phase. Tests ``t25``, ``t26``, ``t27``. The object you pass is not
       recorded, and there is no hierarchy, drain time or callbacks yet.
   * - Factory
     - Partial
     - ``create_component_by_name``, ``create_component_by_type``, ``create_object_by_name``,
       ``create_object_by_type``, ``is_type_name_registered``, ``print``. No overrides yet.
   * - Supporting classes
     - Works
     - ``uvm_scope_stack``, ``uvm_copy_map``, ``uvm_status_container``, ``uvm_comparer``,
       ``uvm_packer`` and ``uvm_printer``. Tests ``t8`` to ``t12``, ``t14``.
   * - Mailbox (``ivl_uvm_mbx``)
     - Works
     - Integer and class payloads. Tests ``t5``, ``t6``.
   * - Simple TLM pull port and export
     - Partial
     - Mailbox-style ``put``/``get`` between components. The TLM classes are placeholders and will
       change.
   * - APB master example
     - Partial
     - Module-based master and slave DUT, test ``t7``. It ends on the global timeout, and the
       regression records that as the expected result.
   * - ``uvm_config_db``, ``uvm_root``, factory overrides
     - Not yet
     - Planned.
   * - Sequences and sequencers
     - Not yet
     - ``uvm_sequence_base`` and ``uvm_sequencer_base`` exist only as placeholders.
   * - ``uvm_env``, ``uvm_agent``
     - Not yet
     - Extend ``uvm_component`` for now. Test ``t23`` builds a test, an env and agents that way.
   * - ``uvm_driver``, ``uvm_monitor``, virtual interfaces
     - Not yet
     - Icarus does not support virtual interfaces today, so a driver or monitor cannot reach DUT
       signals as it does in standard UVM. See :doc:`limitations`.

Changelog
=========

2026-11
-------

Component hierarchy and phasing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* ``uvm_component`` with parent, children, ``get_full_name``, ``get_depth``, ``get_child`` and the other
  child functions (tests ``t20``).
* ``uvm_component_utils`` and ``my_comp::type_id::create(name, parent)`` for components (``t22``).
* ``run_test`` runs the phases ``build`` to ``final`` over the whole component tree, not only the test:
  ``build``, ``run`` and ``final`` top-down, the others bottom-up, oldest child first (``t21``,
  ``t23``, ``t24``). See :doc:`phasing`.
* ``uvm_phase`` accepts ``raise_objection`` and ``drop_objection`` (they have no effect yet).
* The old ``ivl_uvm_run_all_phases`` call is gone; ``run_test`` starts the phases.

Objects, transactions and the registry
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* ``uvm_object``: ``print`` and ``sprint`` (table format), ``copy``, ``clone``, ``compare``, ``pack`` and
  ``unpack``, with ``uvm_printer``, ``uvm_comparer`` and ``uvm_packer`` (``t11`` to ``t14``).
* Field macros ``uvm_field_int``, ``uvm_field_string``, ``uvm_field_enum``, ``uvm_field_real`` and
  ``uvm_field_object``, with ``uvm_object_utils`` and the ``*_begin`` / ``*_end`` form (``t15``).
* ``uvm_transaction`` and ``uvm_sequence_item`` (``t16``, ``t17``, ``t19``).
* ``type_id``, ``get_type`` and ``get_object_type`` for objects (``t18``).
* ``uvm_scope_stack``, ``uvm_copy_map`` and ``uvm_status_container`` (``t8`` to ``t10``).

Factory and test selection
^^^^^^^^^^^^^^^^^^^^^^^^^^

* Factory with ``create_component_by_name``, ``create_object_by_name``, ``create_component_by_type``,
  ``create_object_by_type``, ``is_type_name_registered`` and ``print``.
* Run-time test selection with ``run_test("name")`` and ``+UVM_TESTNAME``.
* ``uvm_test`` is abstract, as in standard UVM.

Regression
^^^^^^^^^^

* Tests ``t0`` to ``t24``; ``make check`` and ``make gold`` compare runs with golden logs.
* ``make check`` now fails on an unknown test number, a failing ``make``, or a missing log, and an
  expected failure (the APB example) is listed in ``expected_fail.list``. A self-test of the runner,
  ``ivl_uvm_check_selftest.sh``, was added. See :doc:`regression`.

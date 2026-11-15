Differences from Standard UVM
=============================

IVL_UVM follows standard UVM wherever Icarus allows it. These are the differences today.

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Standard UVM
     - In IVL_UVM
   * - ``my_test::type_id::create("name", parent)``
     - Not available. Use ``factory.create_component_by_name("my_test", "", "name", parent)``.
   * - ``my_test::type_id::get()``
     - Not available.
   * - ``factory.set_type_override*`` and instance overrides
     - Not yet.
   * - ``uvm_object_utils`` and the ``*_begin`` / ``*_end`` field macros
     - Do not compile yet. Planned.
   * - ``run_test()`` with no test name specified is an error
     - ``run_test()`` looks for a registered test named ``uvm_test``. Since ``uvm_test`` is abstract and
       not registered, this ends with the "not found" fatal. Pass a name or define ``UVM_TESTNAME``.
   * - Component hierarchy, phase objections, ``uvm_config_db``
     - Not yet. The ``parent`` argument is accepted but not tracked.
   * - The factory creates objects only on request
     - The factory also builds one instance of every registered class at time 0 (with ``parent = null``).

Simulator requirements
----------------------

IVL_UVM runs on a development build of Icarus Verilog. Several SystemVerilog features that the
standard UVM source depends on are not supported by Icarus yet, for example parameterized classes,
the ``inside`` operator and ``pure virtual`` methods. IVL_UVM works around them where it can; where
it cannot, the feature is listed above.

One Icarus behaviour to watch for in your own code: calling an overridden virtual method through a
base-class handle does nothing when the base method has an empty body. Put a ``return;`` in an empty
base method that must be overridable.

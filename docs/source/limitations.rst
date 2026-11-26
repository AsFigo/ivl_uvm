Differences from Standard UVM
=============================

IVL_UVM follows standard UVM wherever Icarus allows it. These are the differences today.

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Standard UVM
     - In IVL_UVM
   * - The objection of a phase counts per object and per level of the hierarchy, and has a drain
       time.
     - The run phase keeps one total. There is no hierarchy, drain time or callbacks, and the object
       you pass is not recorded. See :doc:`phasing`.
   * - Every component without a parent is a child of the root component and is phased.
     - Only the tree under the test (``uvm_test_top``) is phased. A component created with
       ``parent = null`` anywhere else gets no phases. There is no ``uvm_root``.
   * - Children are visited and listed in name order.
     - Children are visited and listed in the order they were created (``get_first_child`` gives the
       newest).
   * - The phases are objects in a phase graph.
     - The nine phases run in a fixed order, with one shared phase object.
   * - ``factory.set_type_override*`` and instance overrides
     - Not yet.
   * - ``uvm_config_db``
     - Not yet.
   * - Field macros for arrays, queues and associative arrays
     - Not ported yet. ``uvm_field_int``, ``uvm_field_string``, ``uvm_field_enum``,
       ``uvm_field_real`` and ``uvm_field_object`` work.
   * - Messages show the hierarchical name of the reporting component
     - Messages do not show it. Reporting uses the message ID and text only.
   * - ``reseed`` gives each object its own random seed
     - It has no effect: Icarus does not support random seeding of a class.
   * - Virtual interfaces, drivers and monitors
     - Icarus does not support virtual interfaces today, so code that reaches DUT signals through a
       ``virtual`` interface handle does not work. A module-based example is in test ``t7``.
   * - ``run_test()`` with no test name specified is an error
     - ``run_test()`` looks for a registered test named ``uvm_test``. Since ``uvm_test`` is abstract and
       not registered, this ends with the "not found" fatal. Pass a name or define ``UVM_TESTNAME``.
   * - A component created after the build phase is an error
     - It is not an error. The component gets no ``build_phase``; if its parent is in the tree it takes
       part in the phases that follow.
   * - The factory creates objects only on request
     - The factory also builds one prototype instance of every registered class at time 0 (with
       ``parent = null``).

Simulator requirements
----------------------

IVL_UVM runs on a development build of Icarus Verilog. Several SystemVerilog features that the
standard UVM source depends on are not supported by Icarus yet, for example associative arrays,
queues and dynamic arrays of class handles, and virtual interfaces. IVL_UVM works around them where it
can; where it cannot, the feature is listed above.

Icarus behaviours to watch for in your own code:

* Calling an overridden virtual method through a base-class handle does nothing when the base method
  has an empty body. Put a ``return;`` in an empty base method that must be overridable.
* Write ``this.`` in front of a call to an inherited method inside a method of a derived class
  (``this.get_name()``, not ``get_name()``). Without it Icarus may report that it cannot find the
  function, or, in a method defined outside the class body, call a different function with the same
  name.
* Do not declare an ``event`` as a member of a class (Icarus reports a syntax error). Declare it in a
  package or a module and use it from the class methods.
* Do not use ``wait (expr)`` where ``expr`` reads a class property (the Icarus compiler stops with
  an internal error). Loop on an event instead: ``while (cond) @(ev);``.
* Do not put ``fork ... join_none`` inside a class task or an ``automatic`` task: ``vvp`` aborts when
  it runs. ``fork ... join`` works there.
* ``disable fork`` stops only the threads that were forked in the same block. Threads that were
  forked inside a task you called are not stopped. Fork them in the block that calls
  ``disable fork`` and put that block in an outer ``fork begin ... end join``, so threads your own
  code forked earlier are left alone.

Factory and Test Selection
==========================

Pick the test at run time
-------------------------

Choose the test when you run the simulation, as in standard UVM:

.. code-block:: tcsh

   vvp vw_ivl_ivl_uvm.vvp +UVM_TESTNAME=my_test

You can also pass the name in the source:

.. code-block:: systemverilog

   initial run_test("my_test");

The name comes from the first of these that is set:

#. the argument of ``run_test``
#. ``+UVM_TESTNAME`` on the command line
#. the ``UVM_TESTNAME`` macro at compile time (default ``uvm_test``)

If the name is not registered, the run stops with
``UVM_FATAL [INVTST] Requested test ... not found``.

A test class
------------

A test registers itself with the same macro you use in standard UVM. You write no registration
call.

.. code-block:: systemverilog

   package test_pkg;
     import ivl_uvm_pkg::*;

     class my_test extends uvm_test;
       `uvm_component_utils(my_test)

       function new (string name = "my_test", uvm_component parent = null);
         super.new(name, parent);
       endfunction : new
     endclass : my_test
   endpackage : test_pkg

   module top;
     import ivl_uvm_pkg::*;
     import test_pkg::*;
     initial begin
       run_test();
       $finish;
     end
   endmodule : top

``uvm_test`` is abstract, as in standard UVM, so every test needs a class like ``my_test``.
The constructor must take ``(name, parent)``.

``run_test`` returns after the phases have run, so the module ends the simulation with ``$finish``.
Without it the simulation runs on until the global timeout and reports a timeout error.

The factory
-----------

``factory`` is a global handle, as in UVM.

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Method
     - Purpose
   * - ``create_component_by_name(type, inst_path, name, parent)``
     - Create a registered component
   * - ``create_component_by_type(wrapper, inst_path, name, parent)``
     - Create a component from its ``type_id`` (for example ``my_comp::type_id::get()``)
   * - ``create_object_by_name(type, inst_path, name)``
     - Create a registered object
   * - ``create_object_by_type(wrapper, inst_path, name)``
     - Create an object from its ``type_id``
   * - ``is_type_name_registered(type)``
     - Check that a type is registered
   * - ``print(all_types)``
     - List the registered types in the standard UVM format

Example:

.. code-block:: systemverilog

   uvm_component c;
   c = factory.create_component_by_name("my_test", "", "t0", null);
   factory.print();

Things to know
--------------

* The type name is the class name as written in ``uvm_component_utils`` or ``uvm_object_utils``.
* At time 0 the factory builds one prototype instance of each registered class (named
  ``m_ivl_proto``), passing ``parent = null``. Keep the constructor of a registered class free of
  side effects and do not use ``parent`` there without checking it.
* ``my_class::type_id::create(name, parent)`` works for components and ``type_id::create(name)`` for
  objects, as in standard UVM. ``type_id::get()``, ``get_type()`` and ``get_object_type()`` work too.
* Type and instance overrides are not available yet. See :doc:`limitations`.

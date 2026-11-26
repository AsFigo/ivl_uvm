Phasing: How run_test Runs the Phases
=====================================

``run_test`` creates your test and then runs the phases over the whole component tree: the test,
the components it creates, their children, and so on. This page explains the order in which the
components are visited and how the walk is built.

What you see
------------

Create child components in ``build_phase`` with ``type_id::create(name, parent)``, as in standard
UVM. Every phase then reaches every component in the tree.

.. code-block:: systemverilog

   class my_env extends uvm_component;
     `uvm_component_utils(my_env)
     my_agent agent_a;
     my_agent agent_b;

     function new(string name, uvm_component parent);
       super.new(name, parent);
     endfunction : new

     function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       agent_a = my_agent::type_id::create("agent_a", this);
       agent_b = my_agent::type_id::create("agent_b", this);
     endfunction : build_phase
   endclass : my_env

For a test ``uvm_test_top`` with an ``env`` that has two agents, ``agent_a`` created first, the
phases visit the components in this order:

.. list-table::
   :header-rows: 1
   :widths: 40 20 40

   * - Phase
     - Direction
     - Order of the components
   * - ``build``
     - top-down
     - ``uvm_test_top``, ``env``, ``agent_a``, ``agent_b``
   * - ``connect``, ``end_of_elaboration``, ``start_of_simulation``
     - bottom-up
     - ``agent_a``, ``agent_b``, ``env``, ``uvm_test_top``
   * - ``run``
     - top-down start
     - ``uvm_test_top``, ``env``, ``agent_a``, ``agent_b`` (started together and run in parallel,
       see :ref:`phasing-run`)
   * - ``extract``, ``check``, ``report``
     - bottom-up
     - ``agent_a``, ``agent_b``, ``env``, ``uvm_test_top``
   * - ``final``
     - top-down
     - ``uvm_test_top``, ``env``, ``agent_a``, ``agent_b``

Top-down means a component runs its own phase before its children. Bottom-up means it runs after
them. Siblings are always visited oldest child first (in the order they were created), and each
sibling is finished with all of its own children before the next sibling starts.

A component created in ``build_phase`` takes part in the phases that follow, in the same ``build``
walk: the children of a component are looked up after its own ``build_phase`` has run, so
components it just created are visited too.

How the walk works
------------------

``run_test`` makes the test (named ``uvm_test_top``), then calls one method for each of the nine
phases, in order. Each call walks the whole tree for that phase. Three methods of ``uvm_component``
do the work. They are internal; user code does not call them.

``m_ivl_uvm_walk_subtree(id, phase, direction)``
   Handles one component and everything below it, for one phase. Top-down, it runs the component's
   own phase first and then walks the children. Bottom-up, it walks the children first and then
   runs the component's own phase.

``m_ivl_uvm_walk_siblings_and_children(id, phase, direction, child_node)``
   Handles a list of siblings, starting from ``child_node``, oldest first. For each sibling it
   calls ``m_ivl_uvm_walk_subtree``, so the sibling's children and their descendants are walked
   too.

``m_ivl_uvm_do_one_phase(id, phase)``
   Calls the one phase method (``build_phase``, ``connect_phase``, ``run_phase`` and so on, chosen
   by ``id``) on one component. It never looks at children.

``id`` is a value of ``ivl_uvm_phase_e`` (``IVL_UVM_PHASE_BUILD`` to ``IVL_UVM_PHASE_FINAL``) and
``direction`` is a value of ``ivl_uvm_phase_dir_e`` (``IVL_UVM_TOP_DOWN_PH`` or
``IVL_UVM_BOTTOM_UP_PH``).

Two recursions work together:

#. **Down the tree:** ``m_ivl_uvm_walk_siblings_and_children`` calls ``m_ivl_uvm_walk_subtree`` on a
   child, which walks that child's own children, one level deeper.
#. **Along the children of one component:** ``m_ivl_uvm_walk_siblings_and_children`` calls itself
   for the next older sibling before it handles the node it was given.

The children of a component are kept in a linked list with the newest child at the head, because
Icarus cannot hold class handles in an array or an associative array. Going to the older sibling
first, before handling the current one, is what turns "newest first" into "oldest first".

.. _phasing-run:

The run phase
-------------

The ``run`` phase differs from the others: ``run_phase`` is a task, and in UVM the tasks of all
components run in parallel. ``run_test`` does this in four steps.

#. It walks the tree top-down, as for the other phases, but the walk only collects the components.
   It does not call ``run_phase``.
#. It starts the ``run_phase`` task of every component, in the order of the walk (``uvm_test_top``
   first). All of them start at the same simulation time and run in parallel.
#. It gives the tasks a chance to raise their objections and then waits until the objection count
   of the phase is zero.
#. It stops the ``run_phase`` tasks that are still running (for example a ``forever`` loop that
   never raised an objection) and goes on with the ``extract`` phase.

Objections work as in UVM from the user's side:

.. code-block:: systemverilog

   task run_phase(uvm_phase phase);
     super.run_phase(phase);
     phase.raise_objection(this);
     #100;
     phase.drop_objection(this);
   endtask : run_phase

``raise_objection`` and ``drop_objection`` take the BCL arguments (the object, a description, a
count). As in the BCL, raise the objection in the first time step of the run phase: an objection
raised after time has advanced is not seen, and the run phase has ended by then. A task that
never raises an objection does not hold the run phase open.

A thread that your own test forked before it called ``run_test`` is not stopped when the run phase
ends.

Call stack
----------

This is the call stack for the ``build`` phase (top-down) of the tree ``uvm_test_top`` ->
``env`` -> ``agent_a``, ``agent_b``, where ``agent_a`` was created first. The list of children of
``env`` holds ``agent_b`` at the head and ``agent_a`` after it.

.. code-block:: text

   run_test
    └─ m_ivl_uvm_walk_subtree(uvm_test_top, BUILD, top-down)
        ├─ m_ivl_uvm_do_one_phase(uvm_test_top)             build_phase of the test
        └─ m_ivl_uvm_walk_siblings_and_children(env)        children of the test
            ├─ m_ivl_uvm_walk_siblings_and_children(none)   no older sibling
            └─ m_ivl_uvm_walk_subtree(env)
                ├─ m_ivl_uvm_do_one_phase(env)              build_phase of env
                └─ m_ivl_uvm_walk_siblings_and_children(agent_b)
                    ├─ m_ivl_uvm_walk_siblings_and_children(agent_a)
                    │   ├─ m_ivl_uvm_walk_siblings_and_children(none)
                    │   └─ m_ivl_uvm_walk_subtree(agent_a)
                    │       └─ m_ivl_uvm_do_one_phase(agent_a)    first leaf
                    └─ m_ivl_uvm_walk_subtree(agent_b)
                        └─ m_ivl_uvm_do_one_phase(agent_b)        second leaf

The components run their ``build_phase`` in the order ``uvm_test_top``, ``env``, ``agent_a``,
``agent_b``. The bottom-up phases use the same calls. The only difference is that
``m_ivl_uvm_walk_subtree`` runs the component's own phase after the walk over its children, so the
order is ``agent_a``, ``agent_b``, ``env``, ``uvm_test_top``.

.. _phasing-limits:

Differences from standard UVM
-----------------------------

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Standard UVM
     - In IVL_UVM
   * - The objection of a phase counts per object and per level of the hierarchy, and has a drain
       time.
     - The objection of the run phase keeps one total. ``get_objection_total`` returns it; the object
       you pass to ``raise_objection`` and ``drop_objection`` is not recorded. There is no
       hierarchy, no drain time and no callbacks. Dropping below zero is a fatal error, as in UVM.
   * - Every component without a parent is phased (they are all children of the root component).
     - Only the tree under ``uvm_test_top`` is phased. A component created with ``parent = null``
       anywhere else gets no phases. Planned: a root component.
   * - Siblings are visited in name order.
     - Siblings are visited in the order they were created.
   * - The phases are objects in a phase graph, each with its own state.
     - One phase object is shared by all phases, and the nine phases always run in the fixed order
       above. The walk methods are a stand-in until the phase objects are ported.
   * - A component created after the build phase is an error.
     - It is not an error. The component gets no ``build_phase``; if its parent is in the tree it takes
       part in the phases that follow.

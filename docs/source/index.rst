IVL_UVM
=======

IVL_UVM brings a subset of UVM to the open-source `Icarus Verilog <https://github.com/steveicarus/iverilog>`_
simulator. You write a testbench in familiar UVM style (``uvm_info``, ``uvm_component``, ``uvm_test``,
``run_test``, the factory) and run it with Icarus.

It is a growing subset, not a full UVM. The :doc:`feature_status` page lists what works today and
:doc:`limitations` lists where it differs from standard UVM.

.. note::

   IVL_UVM needs a recent development build of Icarus Verilog, not the stable v11.0 release.

.. toctree::
   :maxdepth: 2
   :caption: Contents

   getting_started
   feature_status
   factory_and_test_selection
   writing_tests
   phasing
   limitations
   regression
   changelog

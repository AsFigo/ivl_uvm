// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_comps.svh
// Author(s): Srinivasan Venkataramanan 
//
// Copyright (c) VerifWorks 2016-2020  All Rights Reserved.
// Contact us via: support@verifworks.com
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 3 as published by the Free Software Foundation.
// 
// This program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// 
// ========== Copyright Header End ============================
////////////////////////////////////////////////////////////////////////

virtual class uvm_void;
  function new ();
  endfunction : new 

 
endclass : uvm_void

class uvm_object extends uvm_void;
  function new ();
    super.new ();
  endfunction : new 

  `ifdef IVL_UVM_I419
  // IVL_UVM issue 416,418 etc.
  `include "ivl_uvm_msg.svh"
  `endif

  virtual function void print ();
    `uvm_info (log_id, "Print", UVM_MEDIUM);
  endfunction : print 

endclass : uvm_object

class uvm_report_object extends uvm_object;
  function new ();
    super.new ();
  endfunction : new 

endclass : uvm_report_object 

class uvm_phase extends uvm_object;
  function new ();
    super.new ();
  endfunction : new 

endclass : uvm_phase 

virtual class uvm_component extends uvm_report_object;
  function new ();
    super.new ();
  endfunction : new 

  virtual function void build_phase(uvm_phase phase);
    `g2u_display ("build_phase")
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    `g2u_display ("connect_phase")
  endfunction : connect_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `g2u_display ("end_of_elaboration_phase")
  endfunction : end_of_elaboration_phase
  virtual function void start_of_simulation_phase(uvm_phase phase);
    `g2u_display ("start_of_simulation_phase")
  endfunction : start_of_simulation_phase

  //virtual task run_phase (uvm_phase phase);
  virtual task run_phase ();
    `g2u_display ("run_phase")
    this.print ();
  endtask : run_phase 

  virtual function void extract_phase(uvm_phase phase);
  endfunction : extract_phase
  virtual function void check_phase(uvm_phase phase);
  endfunction : check_phase
  virtual function void report_phase(uvm_phase phase);
  endfunction : report_phase
  virtual function void final_phase(uvm_phase phase);
  endfunction : final_phase

  virtual task ivl_uvm_run_all_phases ();
    uvm_phase u_ph_0;

    u_ph_0 = new();
    this.build_phase (u_ph_0);
    this.connect_phase (u_ph_0);
    this.end_of_elaboration_phase (u_ph_0);
    this.start_of_simulation_phase (u_ph_0);
    this.run_phase ();
    this.extract_phase (u_ph_0);
    this.check_phase (u_ph_0);
    this.report_phase (u_ph_0);
    this.final_phase (u_ph_0);
  endtask : ivl_uvm_run_all_phases 

endclass : uvm_component

virtual class uvm_test extends uvm_component;
  function new (string name = "uvm_test");
    `g2u_display ("%m");
  endfunction : new 
endclass : uvm_test 

  class sanity_test extends uvm_test;
    function new (string name = "sanity_test");
      super.new(name);
      `g2u_display ("%m");
    endfunction : new
  endclass : sanity_test 

`ifndef UVM_TESTNAME
  `define UVM_TESTNAME uvm_test
`endif // UVM_TESTNAME


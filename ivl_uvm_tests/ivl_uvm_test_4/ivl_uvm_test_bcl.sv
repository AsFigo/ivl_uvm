// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_run_test.sv
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
package test_pkg;
  import ivl_uvm_pkg::*;

  class sanity_test extends uvm_test;
    `uvm_component_utils(sanity_test)
    function new (string name = "sanity_test", uvm_component parent = null);
      super.new(name, parent);
      `g2u_display ("%m");
    endfunction : new
  endclass : sanity_test 

  // uvm_object/uvm_component are virtual: tests need concrete classes
  class af_obj extends uvm_object;
  endclass : af_obj
  class af_comp extends uvm_component;
  endclass : af_comp

endpackage : test_pkg

module ivl_uvm_run_test;
  import ivl_uvm_pkg::*;
  import test_pkg::*;
  af_obj u0;
  af_comp uc_0;
  
  initial begin
    run_test ();
  end

  
   initial begin : test
     #100;
     `uvm_info("IVL_UVM", "UVM_MEDIUM: Hello World", UVM_MEDIUM) 
     u0 = new ();
     u0.print();

     uc_0 = new("uc_0", null);
     uc_0.ivl_uvm_run_all_phases ();

 

     $finish (2);
   end : test

endmodule : ivl_uvm_run_test

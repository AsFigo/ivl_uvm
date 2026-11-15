// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_test_class.sv
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

package af_test_pkg;
  import ivl_uvm_pkg::*;
  class af_obj extends uvm_object;
  endclass : af_obj
  class af_comp extends uvm_component;
  endclass : af_comp
  // uvm_test is abstract: a concrete, registered default test for this file
  class af_test extends uvm_test;
    `uvm_component_utils(af_test)
    function new (string name = "af_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
  endclass : af_test
  export ivl_uvm_pkg::*;
endpackage : af_test_pkg

module ivl_uvm_test_msg;
  import af_test_pkg::*;
  af_obj u0;
  af_comp uc_0;
  
  initial begin
    run_test ("af_test");
  end

   initial begin : test
     #100;
     `uvm_info("IVL_UVM", "UVM_MEDIUM: Hello World", UVM_MEDIUM) 
     u0 = new ("u_0");
     u0.print();

     uc_0 = new("uc_0", null);
     uc_0.ivl_uvm_run_all_phases ();

     $finish (2);

   end : test

endmodule : ivl_uvm_test_msg

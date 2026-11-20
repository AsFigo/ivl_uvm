// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_run_test.sv
// Author(s): Srinivasan Venkataramanan 
//            Ajeetha Kumari Venkatesan
//
// Copyright (c) VerifWorks 2016-2020  All Rights Reserved.
// Contact us via: support@verifworks.com
// Copyright (c) 2026 AsFigo (https://www.asfigo.com)
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of
// the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See
// the License for the specific language governing
// permissions and limitations under the License.
// ========== Copyright Header End ============================
////////////////////////////////////////////////////////////////////////
package test_pkg;
  import ivl_uvm_pkg::*;

  // uvm_object/uvm_component are virtual: tests need concrete classes
  class af_obj extends uvm_object;
  endclass : af_obj
  class af_comp extends uvm_component;
  endclass : af_comp

  // uvm_test is abstract: a concrete, registered default test for this file
  class af_test extends uvm_test;
    `uvm_component_utils(af_test)
    function new (
      string name = "af_test",
      uvm_component parent = null
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new
  endclass : af_test

endpackage : test_pkg

module ivl_uvm_run_test;
  import ivl_uvm_pkg::*;
  import test_pkg::*;
  af_obj u0;
  af_comp uc_0;

  initial begin
    run_test (.test_name("af_test"));
  end

  
   initial begin : test
     #100;
     `uvm_info("IVL_UVM", "UVM_MEDIUM: Hello World", UVM_MEDIUM) 
     u0 = new ();
     u0.print();

     uc_0 = new(
       .name("uc_0"),
       .parent(null)
     );
     uc_0.ivl_uvm_run_all_phases ();
     `g2u_display ("Expect a UVM_TIMEOUT error in this test")
     #10ms;
     `g2u_display ("DO not expect to see this print due to UVM_TIMEOUT error in this test")

     report_summarize ();
   end : test

endmodule : ivl_uvm_run_test

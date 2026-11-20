// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_test_msg.sv
// Author(s): Anirudh Pradyumnan (apseng03@gmail.com)
//            Srinivasan Venkataramanan
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

module ivl_uvm_test_msg;
  import ivl_uvm_pkg::*;
  import test_pkg::*;
  
  initial begin
    run_test (.test_name("af_test"));
  end

   initial begin : test
     #100;
     `uvm_info("IVL_UVM", "UVM_MEDIUM: Hello World", UVM_MEDIUM) 
     `uvm_info("IVL_UVM", "UVM_HIGH: Hello World", UVM_HIGH) 
     `uvm_info("IVL_UVM", "UVM_FULL: Hello World", UVM_FULL) 
     #100 `uvm_info("IVL_UVM", "NONE: Hello World", UVM_NONE) 

     #100 `uvm_warning("IVL_UVM", "Sample Warning!")
     #100 `uvm_error("IVL_UVM", "Sample Error!")
     #100 `uvm_error("IVL_UVM", "Sample Error!")
     #100 `uvm_error("IVL_UVM", "Sample Error!")
     #100 `uvm_fatal("IVL_UVM", "Sample Fatal!")
   end : test

endmodule : ivl_uvm_test_msg

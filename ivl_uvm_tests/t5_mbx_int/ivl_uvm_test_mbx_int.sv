// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_test_mbx_int.sv
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

  class sanity_test extends uvm_test;
    `uvm_component_utils(sanity_test)

    ivl_uvm_mbx i_mbx_0;
    int lv_put_val;
    int lv_get_val;

    function new (
      string name = "sanity_test",
      uvm_component parent = null
    );
      super.new(
        .name(name),
        .parent(parent)
      );
      `g2u_display ("%m");
      i_mbx_0 = new();
    endfunction : new

  endclass : sanity_test 

endpackage : test_pkg

module ivl_uvm_run_test;
  import ivl_uvm_pkg::*;
  import test_pkg::*;
  
  ivl_uvm_mbx i_mbx_0;
  int lv_put_val;
  int lv_get_val;

  task do_puts();
    repeat (10) begin
      lv_put_val = $urandom();
      `g2u_printf (("Test MBX: Put: 0x%0h", lv_put_val))
      i_mbx_0.put (.in_xn(lv_put_val));
      #10;
    end
  endtask : do_puts

  task do_gets();
    repeat (10) begin
      #5;
      i_mbx_0.get (.out_xn(lv_get_val));
      `g2u_printf (("Test MBX: Get: 0x%0h", lv_get_val))
    end
  endtask : do_gets

   initial begin : test
     run_test ();
     #100;
     `uvm_info("IVL_UVM", "UVM_MEDIUM: Hello World", UVM_MEDIUM) 
     i_mbx_0 = new();

     fork
       do_puts();
       do_gets();
     join

     $finish (2);
   end : test

endmodule : ivl_uvm_run_test


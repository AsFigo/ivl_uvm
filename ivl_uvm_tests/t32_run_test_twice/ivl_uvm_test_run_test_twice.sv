// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_run_test_twice.sv
// Author(s): Srinivasan Venkataramanan
//            Ajeetha Kumari Venkatesan
//
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
// Test of a second run_test call: as in the BCL, uvm_test_top exists after the
// first call, so the second call reports the fatal TTINST. The log (compared
// with the golden log) must show the first run completing, then that fatal and
// no "NOT REACHED" line.
package twice_pkg;
  import ivl_uvm_pkg::*;

  class twice_test extends uvm_test;
    `uvm_component_utils(twice_test)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new
  endclass : twice_test
endpackage : twice_pkg

module t_run_test_twice;
  import ivl_uvm_pkg::*;
  import twice_pkg::*;

  initial begin
    run_test(.test_name("twice_test"));
    `uvm_info("TWICE_T", "first run_test returned", UVM_NONE)
    run_test(.test_name("twice_test"));
    `uvm_info("TWICE_T", "NOT REACHED: FAIL  second run_test returned without ending the run", UVM_NONE)
  end
endmodule : t_run_test_twice

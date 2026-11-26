// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_set_timeout_long.sv
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
// Test of uvm_top.set_timeout raising the limit: the default global timeout is
// 1 ms; the test sets 3 ms in its run phase, works for 2 ms and drops its
// objection. The run must end normally at 2 ms (no timeout error at 1 ms).
// Prints PASS or FAIL per check and a final summary line.
package tmo_long_pkg;
  import ivl_uvm_pkg::*;

  class tmo_test extends uvm_test;
    `uvm_component_utils(tmo_test)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(
        .obj(this)
      );
      uvm_top.set_timeout(
        .timeout(3ms),
        .overridable(1)
      );
      #2ms;
      phase.drop_objection(
        .obj(this)
      );
    endtask : run_phase
  endclass : tmo_test
endpackage : tmo_long_pkg

module t_set_timeout_long;
  import ivl_uvm_pkg::*;
  import tmo_long_pkg::*;

  initial begin
    run_test(.test_name("tmo_test"));
    if ($time == 2ms) begin
      `uvm_info("SET_TIMEOUT", "SET_TIMEOUT: PASS (1 checks, 0 failed)", UVM_NONE)
    end
    else begin
      `uvm_error("SET_TIMEOUT", $sformatf("SET_TIMEOUT: FAIL (1 checks, 1 failed) run_test ended at %0t, expected 2 ms", $time))
    end
    // The timer of the command line processor is still waiting for the new limit.
    $finish;
  end
endmodule : t_set_timeout_long

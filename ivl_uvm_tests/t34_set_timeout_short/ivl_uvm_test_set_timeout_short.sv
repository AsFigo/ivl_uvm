// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_set_timeout_short.sv
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
// Test of uvm_top.set_timeout: a first call with overridable = 0 sets the
// global timeout to 300 ns; a second call (100 ns) is refused with the
// NOTIMOUTOVR message, so the run ends with the timeout error at 300 ns and
// not at 100 ns. The log (compared with the golden log) must show that and no
// "NOT REACHED" line.
package tmo_short_pkg;
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
        .timeout(300ns),
        .overridable(0)
      );
      uvm_top.set_timeout(
        .timeout(100ns),
        .overridable(1)
      );
      #1us;
      `uvm_info("TMO_T", "NOT REACHED: FAIL  the timeout did not end the run", UVM_NONE)
      phase.drop_objection(
        .obj(this)
      );
    endtask : run_phase
  endclass : tmo_test
endpackage : tmo_short_pkg

module t_set_timeout_short;
  import ivl_uvm_pkg::*;
  import tmo_short_pkg::*;

  initial begin
    run_test(.test_name("tmo_test"));
  end
endmodule : t_set_timeout_short

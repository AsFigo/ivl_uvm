// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_nba_raise.sv
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
// Test of the end of the run phase when an objection is raised in the first
// time step but only after a nonblocking assignment has taken effect, as the
// BCL allows (it waits for the NBA region before it looks at the objections).
// One component does that, waits 25 time units and drops the objection. The
// run phase must not end before the drop: run_test returns at time 25 and
// the component has run to its end. Prints PASS or FAIL per check and a
// final summary line.
package nba_raise_pkg;
  import ivl_uvm_pkg::*;

  bit nba_flag;
  bit finished;
  int n_fail;
  int n_chk;

  class nba_comp extends uvm_component;
    `uvm_component_utils(nba_comp)

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
      nba_flag <= 1;
      @(nba_flag);
      phase.raise_objection(
        .obj(this)
      );
      #25;
      finished = 1;
      phase.drop_objection(
        .obj(this)
      );
    endtask : run_phase
  endclass : nba_comp

  class nba_test extends uvm_test;
    `uvm_component_utils(nba_test)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new

    function void build_phase(uvm_phase phase);
      nba_comp c;
      super.build_phase(phase);
      c = nba_comp::type_id::create(
        .name("c"),
        .parent(this)
      );
    endfunction : build_phase
  endclass : nba_test

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("NBA_RAISE",
                $sformatf("PASS  %-20s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("NBA_RAISE",
                 $sformatf("FAIL  %-20s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  // Called after run_test has returned.
  function void check_all(int end_time);
    chk_int(
      .what("run_test end time"),
      .got(end_time),
      .exp(25)
    );
    chk_int(
      .what("component finished"),
      .got(finished),
      .exp(1)
    );
    `uvm_info("NBA_RAISE",
              $sformatf("NBA_RAISE: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  endfunction : check_all
endpackage : nba_raise_pkg

module t_nba_raise;
  import ivl_uvm_pkg::*;
  import nba_raise_pkg::*;

  initial begin
    run_test(.test_name("nba_test"));
    check_all(
      .end_time($time)
    );
  end
endmodule : t_nba_raise

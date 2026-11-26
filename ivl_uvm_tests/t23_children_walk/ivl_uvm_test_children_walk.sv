// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_children_walk.sv
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
// Test of the children walk done by run_test: a test creates an env in
// build_phase, the env creates two agents in its build_phase, and every
// phase reaches every component. Each component appends its name to a trace
// per phase; the test checks the order (build top-down, the later function
// phases bottom-up, run one component after another, children in name order) and
// the full names. Prints PASS or FAIL per check and a final summary line.
package children_walk_pkg;
  import ivl_uvm_pkg::*;

  string tr_build;
  string tr_connect;
  string tr_run;
  string tr_report;
  string tr_final;

  class walk_comp extends uvm_component;
    `uvm_component_utils(walk_comp)

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
      super.build_phase(phase);
      tr_build = {tr_build, this.get_name(), " "};
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      tr_connect = {tr_connect, this.get_name(), " "};
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      tr_run = {tr_run, this.get_name(), " "};
    endtask : run_phase

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      tr_report = {tr_report, this.get_name(), " "};
    endfunction : report_phase

    function void final_phase(uvm_phase phase);
      super.final_phase(phase);
      tr_final = {tr_final, this.get_name(), " "};
    endfunction : final_phase
  endclass : walk_comp

  class walk_env extends walk_comp;
    `uvm_component_utils(walk_env)

    walk_comp agent_a;
    walk_comp agent_b;

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
      super.build_phase(phase);
      // Created out of name order on purpose: the walk follows name order.
      agent_b = walk_comp::type_id::create(
        .name("agent_b"),
        .parent(this)
      );
      agent_a = walk_comp::type_id::create(
        .name("agent_a"),
        .parent(this)
      );
    endfunction : build_phase
  endclass : walk_env

  class walk_test extends uvm_test;
    `uvm_component_utils(walk_test)

    walk_env env;
    int n_fail;
    int n_chk;

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new

    function void chk_str(
      string what,
      string got,
      string exp
    );
      n_chk++;
      if (got == exp) begin
        `uvm_info("CHILDREN_WALK",
                  $sformatf("PASS  %-22s got='%s'", what, got),
                  UVM_NONE)
      end
      else begin
        n_fail++;
        `uvm_error("CHILDREN_WALK",
                   $sformatf("FAIL  %-22s got='%s' expected='%s'", what, got, exp))
      end
    endfunction : chk_str

    function void chk_int(
      string what,
      int got,
      int exp
    );
      n_chk++;
      if (got == exp) begin
        `uvm_info("CHILDREN_WALK",
                  $sformatf("PASS  %-22s got=%0d", what, got),
                  UVM_NONE)
      end
      else begin
        n_fail++;
        `uvm_error("CHILDREN_WALK",
                   $sformatf("FAIL  %-22s got=%0d expected=%0d", what, got, exp))
      end
    endfunction : chk_int

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      tr_build = {tr_build, this.get_name(), " "};
      env = walk_env::type_id::create(
        .name("env"),
        .parent(this)
      );
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      tr_connect = {tr_connect, this.get_name(), " "};
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      tr_run = {tr_run, this.get_name(), " "};
    endtask : run_phase

    // The test is the last component of the bottom-up report phase, so every
    // trace is complete when it checks them.
    function void report_phase(uvm_phase phase);
      string nm;
      walk_env e;
      walk_comp a;
      super.report_phase(phase);
      tr_report = {tr_report, this.get_name(), " "};
      chk_str(
        .what("build order"),
        .got(tr_build),
        .exp("uvm_test_top env agent_a agent_b ")
      );
      chk_str(
        .what("connect order"),
        .got(tr_connect),
        .exp("agent_a agent_b env uvm_test_top ")
      );
      chk_str(
        .what("run order"),
        .got(tr_run),
        .exp("uvm_test_top env agent_a agent_b ")
      );
      chk_str(
        .what("report order"),
        .got(tr_report),
        .exp("agent_a agent_b env uvm_test_top ")
      );
      e = env;
      a = null;
      if (e != null) begin
        a = e.agent_b;
      end
      chk_int(
        .what("agent created"),
        .got(a != null),
        .exp(1)
      );
      if (a != null) begin
        nm = a.get_full_name();
        chk_str(
          .what("agent full name"),
          .got(nm),
          .exp("uvm_test_top.env.agent_b")
        );
        chk_int(
          .what("agent depth"),
          .got(a.get_depth()),
          .exp(3)
        );
        chk_int(
          .what("env children"),
          .got(e.get_num_children()),
          .exp(2)
        );
      end
      `uvm_info("CHILDREN_WALK",
                $sformatf("CHILDREN_WALK: %s (%0d checks, %0d failed)",
                          (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
                UVM_NONE)
    endfunction : report_phase

    function void final_phase(uvm_phase phase);
      super.final_phase(phase);
      tr_final = {tr_final, this.get_name(), " "};
    endfunction : final_phase
  endclass : walk_test

  // final_phase runs after report_phase, so its order is checked after
  // run_test has returned. The BCL runs final_phase top-down.
  function void check_final_order();
    string exp;
    exp = "uvm_test_top env agent_a agent_b ";
    if (tr_final == exp) begin
      `uvm_info("CHILDREN_WALK",
                $sformatf("PASS  %-22s got='%s'", "final order", tr_final),
                UVM_NONE)
    end
    else begin
      `uvm_error("CHILDREN_WALK",
                 $sformatf("FAIL  %-22s got='%s' expected='%s'", "final order", tr_final, exp))
    end
  endfunction : check_final_order
endpackage : children_walk_pkg

module t_children_walk;
  import ivl_uvm_pkg::*;
  import children_walk_pkg::*;

  initial begin
    run_test(.test_name("walk_test"));
    check_final_order();
  end
endmodule : t_children_walk

// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_deep_tree.sv
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
////////////////////////////////////////////////////////////////////////
// Test of the children walk on a deeper tree with branches. The test creates
// env1 and env2; env1 creates a1 and a2; a2 creates leaf; env2 creates b1.
// Every component records its name in each phase, so the order of the walk
// is checked for build (top-down), connect and report (bottom-up) and final
// (top-down), together with full names, depth and the child counts. The run
// phase is only counted, not ordered, because the order of the run phases
// will change when they are forked. Everything is checked after run_test has
// returned, which also covers the final phase. Prints PASS or FAIL per check
// and a final summary line.
package deep_tree_pkg;
  import ivl_uvm_pkg::*;

  string tr_build;
  string tr_connect;
  string tr_report;
  string tr_final;
  string tr_full;
  string tr_depth;
  int n_run;
  int n_fail;
  int n_chk;
  int n_env1_kids;
  int n_test_kids;

  class deep_leaf extends uvm_component;
    `uvm_component_utils(deep_leaf)

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
      tr_full = {tr_full, this.get_full_name(), " "};
      tr_depth = {tr_depth, $sformatf("%0d ", this.get_depth())};
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      tr_connect = {tr_connect, this.get_name(), " "};
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      n_run++;
    endtask : run_phase

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      tr_report = {tr_report, this.get_name(), " "};
    endfunction : report_phase

    function void final_phase(uvm_phase phase);
      super.final_phase(phase);
      tr_final = {tr_final, this.get_name(), " "};
    endfunction : final_phase
  endclass : deep_leaf

  // a2: one child, leaf
  class deep_mid extends deep_leaf;
    `uvm_component_utils(deep_mid)

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
      deep_leaf kid;
      super.build_phase(phase);
      kid = deep_leaf::type_id::create(
        .name("leaf"),
        .parent(this)
      );
    endfunction : build_phase
  endclass : deep_mid

  // env1: a1 (a leaf) and a2 (which has a child)
  class deep_env1 extends deep_leaf;
    `uvm_component_utils(deep_env1)

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
      deep_leaf kid_a1;
      deep_mid kid_a2;
      super.build_phase(phase);
      kid_a1 = deep_leaf::type_id::create(
        .name("a1"),
        .parent(this)
      );
      kid_a2 = deep_mid::type_id::create(
        .name("a2"),
        .parent(this)
      );
      n_env1_kids = this.get_num_children();
    endfunction : build_phase
  endclass : deep_env1

  // env2: one child, b1
  class deep_env2 extends deep_leaf;
    `uvm_component_utils(deep_env2)

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
      deep_leaf kid;
      super.build_phase(phase);
      kid = deep_leaf::type_id::create(
        .name("b1"),
        .parent(this)
      );
    endfunction : build_phase
  endclass : deep_env2

  class deep_test extends uvm_test;
    `uvm_component_utils(deep_test)

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
      deep_env1 e1;
      deep_env2 e2;
      super.build_phase(phase);
      tr_build = {tr_build, this.get_name(), " "};
      tr_full = {tr_full, this.get_full_name(), " "};
      tr_depth = {tr_depth, $sformatf("%0d ", this.get_depth())};
      e1 = deep_env1::type_id::create(
        .name("env1"),
        .parent(this)
      );
      e2 = deep_env2::type_id::create(
        .name("env2"),
        .parent(this)
      );
      n_test_kids = this.get_num_children();
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      tr_connect = {tr_connect, this.get_name(), " "};
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      n_run++;
    endtask : run_phase

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      tr_report = {tr_report, this.get_name(), " "};
    endfunction : report_phase

    function void final_phase(uvm_phase phase);
      super.final_phase(phase);
      tr_final = {tr_final, this.get_name(), " "};
    endfunction : final_phase
  endclass : deep_test

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("DEEP_TREE",
                $sformatf("PASS  %-20s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("DEEP_TREE",
                 $sformatf("FAIL  %-20s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("DEEP_TREE",
                $sformatf("PASS  %-20s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("DEEP_TREE",
                 $sformatf("FAIL  %-20s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  // Called after run_test has returned, so every phase has run.
  function void check_all();
    chk_str(
      .what("build order"),
      .got(tr_build),
      .exp("uvm_test_top env1 a1 a2 leaf env2 b1 ")
    );
    chk_str(
      .what("connect order"),
      .got(tr_connect),
      .exp("a1 leaf a2 env1 b1 env2 uvm_test_top ")
    );
    chk_str(
      .what("report order"),
      .got(tr_report),
      .exp("a1 leaf a2 env1 b1 env2 uvm_test_top ")
    );
    chk_str(
      .what("final order"),
      .got(tr_final),
      .exp("uvm_test_top env1 a1 a2 leaf env2 b1 ")
    );
    chk_str(
      .what("full names"),
      .got(tr_full),
      .exp({"uvm_test_top uvm_test_top.env1 uvm_test_top.env1.a1 ",
            "uvm_test_top.env1.a2 uvm_test_top.env1.a2.leaf ",
            "uvm_test_top.env2 uvm_test_top.env2.b1 "})
    );
    chk_str(
      .what("depths"),
      .got(tr_depth),
      .exp("1 2 3 3 4 2 3 ")
    );
    chk_int(
      .what("run phases started"),
      .got(n_run),
      .exp(7)
    );
    chk_int(
      .what("test children"),
      .got(n_test_kids),
      .exp(2)
    );
    chk_int(
      .what("env1 children"),
      .got(n_env1_kids),
      .exp(2)
    );
    `uvm_info("DEEP_TREE",
              $sformatf("DEEP_TREE: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  endfunction : check_all
endpackage : deep_tree_pkg

module t_deep_tree;
  import ivl_uvm_pkg::*;
  import deep_tree_pkg::*;

  initial begin
    run_test(.test_name("deep_test"));
    check_all();
  end
endmodule : t_deep_tree

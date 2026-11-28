// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_env.sv
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
// Test of uvm_env: the constructor defaults, the type name, and an env with a
// sub-env built by a test through run_test. Checks names, parents, the phase
// order over the two envs and creation by type name through the factory.
// Prints PASS or FAIL per check and a final summary line.
package env_pkg;
  import ivl_uvm_pkg::*;

  string tr_build;
  string tr_connect;
  string tr_run;

  // Uses the uvm_env constructor defaults and has no factory macro, so it
  // reports the type name of uvm_env.
  class default_env extends uvm_env;
    function new();
      super.new();
    endfunction : new
  endclass : default_env

  class leaf_env extends uvm_env;
    `uvm_component_utils(leaf_env)

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
  endclass : leaf_env

  class top_env extends uvm_env;
    `uvm_component_utils(top_env)

    leaf_env sub_env;

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
      sub_env = leaf_env::type_id::create(
        .name("sub_env"),
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
  endclass : top_env

  // The env built by the test, kept for the checks after run_test.
  top_env built_env;

  class env_test extends uvm_test;
    `uvm_component_utils(env_test)

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
      built_env = top_env::type_id::create(
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
  endclass : env_test
endpackage : env_pkg

module t_env;
  import ivl_uvm_pkg::*;
  import env_pkg::*;

  int n_fail;
  int n_chk;

  function void chk_s(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("ENV",
                $sformatf("PASS  %-26s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("ENV",
                 $sformatf("FAIL  %-26s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_s

  function void chk_i(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("ENV",
                $sformatf("PASS  %-26s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("ENV",
                 $sformatf("FAIL  %-26s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_i

  default_env d_env;
  top_env t_env_h;
  leaf_env s_env;
  uvm_env as_env;
  uvm_component as_comp;
  uvm_component by_name;
  string nm;

  initial begin
    // constructor defaults: name "env", parent null (a child of uvm_top)
    d_env = new();
    nm = d_env.get_name();
    chk_s(
      .what("default name"),
      .got(nm),
      .exp("env")
    );
    chk_i(
      .what("default parent is uvm_top"),
      .got(d_env.get_parent() == uvm_top),
      .exp(1)
    );
    nm = d_env.get_type_name();
    chk_s(
      .what("uvm_env type name"),
      .got(nm),
      .exp("uvm_env")
    );
    as_comp = d_env;
    chk_i(
      .what("component casts to env"),
      .got($cast(as_env, as_comp)),
      .exp(1)
    );

    run_test(
      .test_name("env_test")
    );

    chk_s(
      .what("build order"),
      .got(tr_build),
      .exp("uvm_test_top env sub_env ")
    );
    chk_s(
      .what("connect order"),
      .got(tr_connect),
      .exp("sub_env env uvm_test_top ")
    );
    chk_s(
      .what("run start order"),
      .got(tr_run),
      .exp("uvm_test_top env sub_env ")
    );

    t_env_h = built_env;
    nm = t_env_h.get_full_name();
    chk_s(
      .what("env full name"),
      .got(nm),
      .exp("uvm_test_top.env")
    );
    nm = t_env_h.get_type_name();
    chk_s(
      .what("env type name"),
      .got(nm),
      .exp("top_env")
    );
    s_env = t_env_h.sub_env;
    nm = s_env.get_full_name();
    chk_s(
      .what("sub env full name"),
      .got(nm),
      .exp("uvm_test_top.env.sub_env")
    );
    chk_i(
      .what("sub env parent is env"),
      .got(s_env.get_parent() == t_env_h),
      .exp(1)
    );

    // by type name through the factory
    by_name = factory.create_component_by_name(
      .requested_type_name("leaf_env"),
      .name("by_name"),
      .parent(t_env_h)
    );
    chk_i(
      .what("by name is a uvm_env"),
      .got($cast(as_env, by_name)),
      .exp(1)
    );

    `uvm_info("ENV",
              $sformatf("ENV: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_env

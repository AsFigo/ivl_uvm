// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_find_topology.sv
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
// Test of the root component's search and topology print: uvm_is_match (glob
// patterns with * and ?), uvm_top.find, uvm_top.find_all and
// uvm_top.print_topology, on a tree built out of name order (agent_b before
// agent_a) plus a top-level component. The topology print itself is checked
// through the golden log. Prints PASS or FAIL per check and a final summary
// line.
package find_topology_pkg;
  import ivl_uvm_pkg::*;

  int n_fail;
  int n_chk;

  class ft_comp extends uvm_component;
    `uvm_component_utils(ft_comp)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new
  endclass : ft_comp

  class ft_env extends ft_comp;
    `uvm_component_utils(ft_env)

    ft_comp agent_a;
    ft_comp agent_b;

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
      agent_b = ft_comp::type_id::create(
        .name("agent_b"),
        .parent(this)
      );
      agent_a = ft_comp::type_id::create(
        .name("agent_a"),
        .parent(this)
      );
    endfunction : build_phase
  endclass : ft_env

  class ft_test extends uvm_test;
    `uvm_component_utils(ft_test)

    ft_env env;

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
      env = ft_env::type_id::create(
        .name("env"),
        .parent(this)
      );
    endfunction : build_phase
  endclass : ft_test

  ft_comp orph;

  function void chk_bit(
    string what,
    bit got
  );
    n_chk++;
    if (got) begin
      `uvm_info("FIND_TOPO",
                $sformatf("PASS  %-30s", what),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("FIND_TOPO",
                 $sformatf("FAIL  %-30s", what))
    end
  endfunction : chk_bit

  function void chk_match(
    string expr,
    string str,
    bit exp
  );
    chk_bit(
      .what($sformatf("match '%s' '%s' -> %0d", expr, str, exp)),
      .got(uvm_is_match(.expr(expr), .str(str)) == exp)
    );
  endfunction : chk_match

  function void make_orphan();
    orph = ft_comp::type_id::create(
      .name("zz_orph"),
      .parent(null)
    );
  endfunction : make_orphan

  // Called after run_test has returned (the tree stays).
  function void check_all();
    ft_test t;
    ft_env e;
    ivl_uvm_string_list #(uvm_component) hits;
    ivl_uvm_ll_node #(string, uvm_component) n;
    uvm_component c;
    string s;
    if (!$cast(t, uvm_test_top)) begin
      `uvm_fatal("FIND_TOPO", "uvm_test_top is not an ft_test")
    end
    // A member of a member handle is not supported by Icarus: copy to a local.
    e = t.env;

    chk_match(.expr("*"), .str(""), .exp(1));
    chk_match(.expr("a*c"), .str("abbc"), .exp(1));
    chk_match(.expr("a*c"), .str("abbd"), .exp(0));
    chk_match(.expr("a?c"), .str("abc"), .exp(1));
    chk_match(.expr("a?c"), .str("ac"), .exp(0));
    chk_match(.expr("uvm_*"), .str("uvm_test_top"), .exp(1));
    chk_match(.expr("*.agent_?"), .str("uvm_test_top.env.agent_a"), .exp(1));
    chk_match(.expr("env"), .str("env.x"), .exp(0));

    c = uvm_top.find(.comp_match("uvm_test_top.env.agent_a"));
    chk_bit(
      .what("find exact full name"),
      .got(c == e.agent_a)
    );
    c = uvm_top.find(.comp_match("*.agent_b"));
    chk_bit(
      .what("find *.agent_b"),
      .got(c == e.agent_b)
    );
    c = uvm_top.find(.comp_match("zz_orph"));
    chk_bit(
      .what("find top-level component"),
      .got(c == orph)
    );
    c = uvm_top.find(.comp_match("nosuch"));
    chk_bit(
      .what("find no match is null"),
      .got(c == null)
    );

    hits = new;
    uvm_top.find_all(
      .comp_match("*agent*"),
      .comps(hits)
    );
    chk_bit(
      .what("find_all *agent* count"),
      .got(hits.size() == 2)
    );
    s = "";
    n = hits.first_node();
    while (n != null) begin
      s = {s, n.key, " "};
      n = n.next;
    end
    chk_bit(
      .what("find_all names"),
      .got(s == "uvm_test_top.env.agent_a uvm_test_top.env.agent_b ")
    );

    uvm_top.print_topology();

    `uvm_info("FIND_TOPO",
              $sformatf("FIND_TOPO: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  endfunction : check_all
endpackage : find_topology_pkg

module t_find_topology;
  import ivl_uvm_pkg::*;
  import find_topology_pkg::*;

  initial begin
    make_orphan();
    run_test(.test_name("ft_test"));
    check_all();
  end
endmodule : t_find_topology

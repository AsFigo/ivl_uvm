// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_component.sv
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
// Direct test of uvm_component hierarchy: name, parent, full name, depth,
// children (get_child, has_child, get_num_children, first/next iteration)
// and the generated name for an empty name. Prints PASS or FAIL per check
// and a final summary line.
module t_component;
  import ivl_uvm_pkg::*;

  // uvm_component is abstract, so the test uses a plain derived class.
  class my_comp extends uvm_component;
    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new
  endclass : my_comp

  int n_fail;
  int n_chk;

  function void chk_s(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("COMPONENT",
                $sformatf("PASS  %-26s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COMPONENT",
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
      `uvm_info("COMPONENT",
                $sformatf("PASS  %-26s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COMPONENT",
                 $sformatf("FAIL  %-26s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_i

  my_comp top;
  my_comp a;
  my_comp b;
  my_comp aa;
  my_comp anon;
  uvm_component got_c;
  string nm;
  string anon_name;
  int n_seen;

  initial begin
    top = new(
      .name("top"),
      .parent(null)
    );
    chk_s(
      .what("top name"),
      .got(top.get_name()),
      .exp("top")
    );
    chk_s(
      .what("top full name"),
      .got(top.get_full_name()),
      .exp("top")
    );
    chk_i(
      .what("top parent is uvm_top"),
      .got(top.get_parent() == uvm_top),
      .exp(1)
    );
    chk_i(
      .what("top depth"),
      .got(top.get_depth()),
      .exp(1)
    );
    chk_i(
      .what("top children"),
      .got(top.get_num_children()),
      .exp(0)
    );

    a = new(
      .name("a"),
      .parent(top)
    );
    b = new(
      .name("b"),
      .parent(top)
    );
    aa = new(
      .name("aa"),
      .parent(a)
    );
    chk_s(
      .what("child full name"),
      .got(a.get_full_name()),
      .exp("top.a")
    );
    chk_s(
      .what("grandchild full name"),
      .got(aa.get_full_name()),
      .exp("top.a.aa")
    );
    chk_i(
      .what("child parent is top"),
      .got(a.get_parent() == top),
      .exp(1)
    );
    chk_i(
      .what("grandchild parent is a"),
      .got(aa.get_parent() == a),
      .exp(1)
    );
    chk_i(
      .what("grandchild depth"),
      .got(aa.get_depth()),
      .exp(3)
    );
    chk_i(
      .what("top children after add"),
      .got(top.get_num_children()),
      .exp(2)
    );
    chk_i(
      .what("a children"),
      .got(a.get_num_children()),
      .exp(1)
    );
    chk_i(
      .what("top has_child a"),
      .got(top.has_child(.name("a"))),
      .exp(1)
    );
    chk_i(
      .what("top has_child zz"),
      .got(top.has_child(.name("zz"))),
      .exp(0)
    );
    got_c = top.get_child(.name("b"));
    chk_i(
      .what("get_child b"),
      .got(got_c == b),
      .exp(1)
    );
    got_c = top.get_child(.name("zz"));
    chk_i(
      .what("get_child zz is null"),
      .got(got_c == null),
      .exp(1)
    );

    n_seen = 0;
    if (top.get_first_child(.name(nm))) begin
      do begin
        n_seen++;
      end
      while (top.get_next_child(.name(nm)));
    end
    chk_i(
      .what("first/next visits all"),
      .got(n_seen),
      .exp(2)
    );

    anon = new(
      .name(""),
      .parent(top)
    );
    anon_name = anon.get_name();
    chk_i(
      .what("empty name gets COMP_"),
      .got(anon_name.substr(0, 4) == "COMP_"),
      .exp(1)
    );

    `uvm_info("COMPONENT",
              $sformatf("COMPONENT: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_component

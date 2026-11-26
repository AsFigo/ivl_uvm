// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_uvm_root.sv
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
// Test of the root component (uvm_root, global uvm_top). As in the BCL, uvm_top
// is created once (uvm_root::get() returns the same object), its name is
// empty, and every component created with parent null becomes a child of it,
// including uvm_test_top. The children of uvm_top come back in name order.
// Prints PASS or FAIL per check and a final summary line.
package uvm_root_pkg;
  import ivl_uvm_pkg::*;

  int n_fail;
  int n_chk;
  int n_build_a;

  class root_comp extends uvm_component;
    `uvm_component_utils(root_comp)

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
      if (this.get_name() == "a_orph") begin
        n_build_a++;
      end
    endfunction : build_phase
  endclass : root_comp

  class root_test extends uvm_test;
    `uvm_component_utils(root_test)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new
  endclass : root_test

  root_comp orph_z;
  root_comp orph_a;
  root_comp kid;

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("UVM_ROOT",
                $sformatf("PASS  %-26s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("UVM_ROOT",
                 $sformatf("FAIL  %-26s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  function void chk_bit(
    string what,
    bit got
  );
    n_chk++;
    if (got) begin
      `uvm_info("UVM_ROOT",
                $sformatf("PASS  %-26s", what),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("UVM_ROOT",
                 $sformatf("FAIL  %-26s", what))
    end
  endfunction : chk_bit

  // Children of uvm_top by get_first_child / get_next_child, joined by blanks.
  function string top_children();
    string nm;
    string s;
    s = "";
    if (uvm_top.get_first_child(.name(nm))) begin
      do begin
        s = {s, nm, " "};
      end while (uvm_top.get_next_child(.name(nm)));
    end
    return s;
  endfunction : top_children

  // Before run_test.
  function void check_before();
    uvm_root r;
    r = uvm_root::get();
    chk_bit(
      .what("uvm_top exists"),
      .got(uvm_top != null)
    );
    chk_bit(
      .what("get() is uvm_top"),
      .got(r == uvm_top)
    );
    chk_str(
      .what("uvm_top name"),
      .got(uvm_top.get_name()),
      .exp("")
    );
    chk_str(
      .what("uvm_top full name"),
      .got(uvm_top.get_full_name()),
      .exp("")
    );
    orph_z = root_comp::type_id::create(
      .name("z_orph"),
      .parent(null)
    );
    orph_a = root_comp::type_id::create(
      .name("a_orph"),
      .parent(null)
    );
    kid = root_comp::type_id::create(
      .name("kid"),
      .parent(orph_a)
    );
    chk_bit(
      .what("orphan parent is uvm_top"),
      .got(orph_a.get_parent() == uvm_top)
    );
    chk_bit(
      .what("uvm_top has a_orph"),
      .got(uvm_top.has_child(.name("a_orph")))
    );
    chk_bit(
      .what("uvm_top get_child"),
      .got(uvm_top.get_child(.name("z_orph")) == orph_z)
    );
    chk_str(
      .what("orphan full name"),
      .got(orph_a.get_full_name()),
      .exp("a_orph")
    );
    chk_str(
      .what("kid full name"),
      .got(kid.get_full_name()),
      .exp("a_orph.kid")
    );
    chk_str(
      .what("children before run"),
      .got(top_children()),
      .exp("a_orph z_orph ")
    );
  endfunction : check_before

  // After run_test has returned.
  function void check_after();
    chk_bit(
      .what("test is a child of top"),
      .got(uvm_top.get_child(.name("uvm_test_top")) == uvm_test_top)
    );
    chk_bit(
      .what("test parent is uvm_top"),
      .got(uvm_test_top.get_parent() == uvm_top)
    );
    chk_str(
      .what("children after run"),
      .got(top_children()),
      .exp("a_orph uvm_test_top z_orph ")
    );
    chk_str(
      .what("test full name"),
      .got(uvm_test_top.get_full_name()),
      .exp("uvm_test_top")
    );
    chk_str(
      .what("builds of a_orph"),
      .got($sformatf("%0d", n_build_a)),
      .exp("1")
    );
    `uvm_info("UVM_ROOT",
              $sformatf("UVM_ROOT: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  endfunction : check_after
endpackage : uvm_root_pkg

module t_uvm_root;
  import ivl_uvm_pkg::*;
  import uvm_root_pkg::*;

  initial begin
    check_before();
    run_test(.test_name("root_test"));
    check_after();
  end
endmodule : t_uvm_root

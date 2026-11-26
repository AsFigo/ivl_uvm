// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_objections.sv
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
////////////////////////////////////////////////////////////////////////
// Test of the objection counter on the run phase. A test with two children
// runs through run_test. Child c1 raises and drops objections with different
// counts and records the phase total after every call; child c2 never raises
// an objection and records the total it sees. All checks run after run_test
// has returned: the totals seen along the way, the total at the end (zero),
// and that run_test came back at all. Prints PASS or FAIL per check and a
// final summary line.
package objections_pkg;
  import ivl_uvm_pkg::*;

  string tr_c1;
  string tr_c2;
  int n_fail;
  int n_chk;
  int end_total;
  bit have_objection;

  class obj_c1 extends uvm_component;
    `uvm_component_utils(obj_c1)

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
      uvm_objection o;
      super.run_phase(phase);
      o = phase.get_objection();
      tr_c1 = {tr_c1, $sformatf("%0d ", o.get_objection_total())};
      phase.raise_objection(
        .obj(this)
      );
      tr_c1 = {tr_c1, $sformatf("%0d ", o.get_objection_total())};
      phase.raise_objection(
        .obj(this),
        .description("two more"),
        .count(2)
      );
      tr_c1 = {tr_c1, $sformatf("%0d ", o.get_objection_total())};
      phase.drop_objection(
        .obj(this)
      );
      tr_c1 = {tr_c1, $sformatf("%0d ", o.get_objection_total())};
      phase.drop_objection(
        .obj(this),
        .description("last two"),
        .count(2)
      );
      tr_c1 = {tr_c1, $sformatf("%0d ", o.get_objection_total())};
    endtask : run_phase
  endclass : obj_c1

  // c2 never raises an objection; it records the total it sees.
  class obj_c2 extends uvm_component;
    `uvm_component_utils(obj_c2)

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
      uvm_objection o;
      super.run_phase(phase);
      o = phase.get_objection();
      tr_c2 = {tr_c2, $sformatf("%0d ", o.get_objection_total())};
    endtask : run_phase
  endclass : obj_c2

  class obj_test extends uvm_test;
    `uvm_component_utils(obj_test)

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
      obj_c1 c1;
      obj_c2 c2;
      super.build_phase(phase);
      c1 = obj_c1::type_id::create(
        .name("c1"),
        .parent(this)
      );
      c2 = obj_c2::type_id::create(
        .name("c2"),
        .parent(this)
      );
    endfunction : build_phase

    function void report_phase(uvm_phase phase);
      uvm_objection o;
      super.report_phase(phase);
      o = phase.get_objection();
      have_objection = (o != null);
      if (o != null) begin
        end_total = o.get_objection_total();
      end
    endfunction : report_phase
  endclass : obj_test

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("OBJECTIONS",
                $sformatf("PASS  %-20s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("OBJECTIONS",
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
      `uvm_info("OBJECTIONS",
                $sformatf("PASS  %-20s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("OBJECTIONS",
                 $sformatf("FAIL  %-20s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  // Called after run_test has returned.
  function void check_all();
    chk_int(
      .what("objection object"),
      .got(have_objection),
      .exp(1)
    );
    chk_str(
      .what("c1 totals"),
      .got(tr_c1),
      .exp("0 1 3 2 0 ")
    );
    chk_str(
      .what("c2 total"),
      .got(tr_c2),
      .exp("0 ")
    );
    chk_int(
      .what("total at report"),
      .got(end_total),
      .exp(0)
    );
    `uvm_info("OBJECTIONS",
              $sformatf("OBJECTIONS: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  endfunction : check_all
endpackage : objections_pkg

module t_objections;
  import ivl_uvm_pkg::*;
  import objections_pkg::*;

  initial begin
    run_test(.test_name("obj_test"));
    check_all();
  end
endmodule : t_objections

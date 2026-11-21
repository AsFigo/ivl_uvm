// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_run_test_phases.sv
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
// run_test and the phase methods, written the way a user writes them: a
// uvm_test with uvm_component_utils overrides build, connect, run and report
// phases, makes an item with type_id::create in build_phase, fills and prints
// it in run_phase, and is started by run_test. Each phase leaves a mark;
// report_phase checks that the phases ran once each, in order, and prints PASS
// or FAIL per check and a final summary line. This checks the user-facing
// shape for a single component. The phases are called one after another on
// that component (no root component, no children, no forked run_phase), and
// run_phase raises and drops an objection that is accepted and ignored for now.
package run_test_phases_pkg;
  import ivl_uvm_pkg::*;

  typedef enum {READ, WRITE} kind_e;

  class my_item extends uvm_sequence_item;
    bit [15:0] addr;
    int data;
    kind_e kind;

    `uvm_object_utils_begin(my_item)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON | UVM_DEC)
      `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "my_item");
      super.new(name);
    endfunction : new
  endclass : my_item

  class my_test extends uvm_test;
    `uvm_component_utils(my_test)

    my_item item;
    string trace;
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
        `uvm_info("RUN_PHASES",
                  $sformatf("PASS  %-26s got='%s'", what, got),
                  UVM_NONE)
      end
      else begin
        n_fail++;
        `uvm_error("RUN_PHASES",
                   $sformatf("FAIL  %-26s got='%s' expected='%s'", what, got, exp))
      end
    endfunction : chk_str

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      trace = {trace, "build "};
      item = my_item::type_id::create(.name("item"));
      `uvm_info("RUN_PHASES", "build_phase: item created", UVM_LOW)
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      trace = {trace, "connect "};
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(.obj(this));
      trace = {trace, "run "};
      item.addr = 16'h1000;
      item.data = 42;
      item.kind = WRITE;
      item.print();
      #10;
      phase.drop_objection(.obj(this));
    endtask : run_phase

    function void report_phase(uvm_phase phase);
      string nm;
      super.report_phase(phase);
      trace = {trace, "report"};
      chk_str(
        .what("phase order"),
        .got(trace),
        .exp("build connect run report")
      );
      nm = this.get_full_name();
      chk_str(
        .what("test full name"),
        .got(nm),
        .exp("uvm_test_top")
      );
      nm = item.get_name();
      chk_str(
        .what("item name"),
        .got(nm),
        .exp("item")
      );
      `uvm_info("RUN_PHASES",
                $sformatf("RUN_PHASES: %s (%0d checks, %0d failed)",
                          (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
                UVM_NONE)
    endfunction : report_phase
  endclass : my_test
endpackage : run_test_phases_pkg

module t_run_test_phases;
  import ivl_uvm_pkg::*;
  import run_test_phases_pkg::*;

  initial begin
    run_test(.test_name("my_test"));
  end
endmodule : t_run_test_phases

// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_orphan_components.sv
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
// Test of top-level components (created with parent = null, outside the
// test tree). In the BCL they hang under the root component, so run_test
// runs every phase on them as well. Two such components are created before
// run_test; each must see each of the nine phases exactly once, and the
// test component (uvm_test_top) must still see them too. Prints PASS or
// FAIL per check and a final summary line.
package orphan_pkg;
  import ivl_uvm_pkg::*;

  int n_fail;
  int n_chk;

  class phase_counter extends uvm_component;
    int n_build;
    int n_connect;
    int n_eoe;
    int n_sos;
    int n_run;
    int n_extract;
    int n_check;
    int n_report;
    int n_final;

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
      n_build++;
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      n_connect++;
    endfunction : connect_phase

    function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      n_eoe++;
    endfunction : end_of_elaboration_phase

    function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      n_sos++;
    endfunction : start_of_simulation_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      n_run++;
    endtask : run_phase

    function void extract_phase(uvm_phase phase);
      super.extract_phase(phase);
      n_extract++;
    endfunction : extract_phase

    function void check_phase(uvm_phase phase);
      super.check_phase(phase);
      n_check++;
    endfunction : check_phase

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      n_report++;
    endfunction : report_phase

    function void final_phase(uvm_phase phase);
      super.final_phase(phase);
      n_final++;
    endfunction : final_phase
  endclass : phase_counter

  class orphan_comp extends phase_counter;
    `uvm_component_utils(orphan_comp)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new
  endclass : orphan_comp

  class orphan_test extends uvm_test;
    `uvm_component_utils(orphan_test)

    int n_build;
    int n_final;

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
      n_build++;
    endfunction : build_phase

    function void final_phase(uvm_phase phase);
      super.final_phase(phase);
      n_final++;
    endfunction : final_phase
  endclass : orphan_test

  orphan_comp orphan_a;
  orphan_comp orphan_b;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("ORPHAN",
                $sformatf("PASS  %-24s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("ORPHAN",
                 $sformatf("FAIL  %-24s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  function void chk_all_phases(
    string who,
    phase_counter c
  );
    chk_int(
      .what({who, " build"}),
      .got(c.n_build),
      .exp(1)
    );
    chk_int(
      .what({who, " connect"}),
      .got(c.n_connect),
      .exp(1)
    );
    chk_int(
      .what({who, " end_of_elab"}),
      .got(c.n_eoe),
      .exp(1)
    );
    chk_int(
      .what({who, " start_of_sim"}),
      .got(c.n_sos),
      .exp(1)
    );
    chk_int(
      .what({who, " run"}),
      .got(c.n_run),
      .exp(1)
    );
    chk_int(
      .what({who, " extract"}),
      .got(c.n_extract),
      .exp(1)
    );
    chk_int(
      .what({who, " check"}),
      .got(c.n_check),
      .exp(1)
    );
    chk_int(
      .what({who, " report"}),
      .got(c.n_report),
      .exp(1)
    );
    chk_int(
      .what({who, " final"}),
      .got(c.n_final),
      .exp(1)
    );
  endfunction : chk_all_phases

  // Called before run_test: creates the top-level components.
  function void make_orphans();
    orphan_a = orphan_comp::type_id::create(
      .name("orphan_a"),
      .parent(null)
    );
    orphan_b = orphan_comp::type_id::create(
      .name("orphan_b"),
      .parent(null)
    );
  endfunction : make_orphans

  // Called after run_test has returned.
  function void check_all();
    orphan_test t;
    if (!$cast(t, uvm_test_top)) begin
      `uvm_fatal("ORPHAN", "uvm_test_top is not an orphan_test")
    end
    chk_int(
      .what("test build"),
      .got(t.n_build),
      .exp(1)
    );
    chk_int(
      .what("test final"),
      .got(t.n_final),
      .exp(1)
    );
    chk_all_phases(
      .who("orphan_a"),
      .c(orphan_a)
    );
    chk_all_phases(
      .who("orphan_b"),
      .c(orphan_b)
    );
    `uvm_info("ORPHAN",
              $sformatf("ORPHAN: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  endfunction : check_all
endpackage : orphan_pkg

module t_orphan;
  import ivl_uvm_pkg::*;
  import orphan_pkg::*;

  initial begin
    make_orphans();
    run_test(.test_name("orphan_test"));
    check_all();
  end
endmodule : t_orphan

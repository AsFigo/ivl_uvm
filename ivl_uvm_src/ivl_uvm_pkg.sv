// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_pkg.sv
// Author(s): Anirudh Pradyumnan (apseng03@gmail.com)
//            Srinivasan Venkataramanan
//            Ajeetha Kumari Venkatesan
//
// Copyright (c) VerifWorks 2016-2020  All Rights Reserved.
// Contact us via: support@verifworks.com
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
`ifndef IVL_UVM_PKG
  `define IVL_UVM_PKG

  `define IVL_UVM
  `define UVM_CMDLINE_NO_DPI
`timescale 1ns/1ns

package ivl_uvm_pkg;
  `include "ivl_uvm_macros.svh"
  `include "ivl_uvm_types.svh"

  `include "ivl_uvm_patches.svh"
  `include "ivl_uvm_msg.svh"
  `include "base/uvm_misc.svh"
  `include "base/uvm_globals.svh"
  `include "base/uvm_object.svh"
  `include "base/uvm_comparer.svh"
  `include "base/uvm_packer.svh"
  `include "base/uvm_printer.svh"
  `include "base/uvm_transaction.svh"
  `include "seq/uvm_sequence_item.svh"
  `include "ivl_uvm_comps.svh"
  `include "base/ivl_uvm_factory.svh"
  `include "base/uvm_registry.svh"
  `include "ivl_uvm_mbx.svh"
  `include "ivl_uvm_tlm.svh"

  uvm_component uvm_test_top;

  // Test selected at run time: run_test("name") or +UVM_TESTNAME=name; the
  // compile-time `UVM_TESTNAME (default uvm_test) is used when neither is given.
  task run_test (string test_name = "");
    string tn;
    uvm_phase u_ph_0;
    uvm_objection run_done;
    ivl_uvm_ll_node #(string, uvm_component) run_node;
    uvm_component run_comp;
    if (test_name != "") begin
      tn = test_name;
    end
    else if (!`IVL_UVM_VPA ("UVM_TESTNAME=%s", tn)) begin
      tn = `GO2UVM_DISP_ARG (`UVM_TESTNAME);
    end
    `g2u_printf (( "Using UVM_TESTNAME: %s", tn ))
    m_ivl_init_factory();
    uvm_test_top = factory.create_component_by_name (tn, "", "uvm_test_top", null);
    if (uvm_test_top == null) begin
      uvm_report_fatal ("INVTST", $sformatf ("Requested test %s not found (not registered with `uvm_component_utils, or abstract like uvm_test?)", tn), UVM_NONE, `uvm_file, `uvm_line);
      return;
    end
    // Stand-in for the root component's phasing: every phase is run over the
    // whole tree, one phase after the other (build, run and final top-down, as
    // in the BCL; the others bottom-up).
    u_ph_0 = new();
    uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_BUILD, u_ph_0, IVL_UVM_TOP_DOWN_PH);
    uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_CONNECT, u_ph_0, IVL_UVM_BOTTOM_UP_PH);
    uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_END_OF_ELABORATION, u_ph_0, IVL_UVM_BOTTOM_UP_PH);
    uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_START_OF_SIMULATION, u_ph_0, IVL_UVM_BOTTOM_UP_PH);
    // The run phases are forked, one per component, from this block (a fork
    // started inside another task would not be stopped by disable fork). The
    // run phase ends when every objection is dropped; the tasks still running
    // are then stopped.
    run_done = u_ph_0.get_objection();
    fork
      begin
        // Collects the components; run_phase itself is not called here.
        uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_RUN, u_ph_0, IVL_UVM_TOP_DOWN_PH);
        run_node = u_ph_0.m_ivl_uvm_first_run_comp();
        while (run_node != null) begin
          run_comp = run_node.val;
          fork
            run_comp.run_phase(u_ph_0);
          join_none
          // The new thread copies run_comp before the next one is started.
          #0;
          run_node = run_node.next;
        end
        // Give the run phases a chance to object (BCL: wait for the NBA region).
        uvm_wait_for_nba_region();
        run_done.m_ivl_uvm_wait_all_dropped();
        disable fork;
      end
    join
    uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_EXTRACT, u_ph_0, IVL_UVM_BOTTOM_UP_PH);
    uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_CHECK, u_ph_0, IVL_UVM_BOTTOM_UP_PH);
    uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_REPORT, u_ph_0, IVL_UVM_BOTTOM_UP_PH);
    uvm_test_top.m_ivl_uvm_walk_subtree(IVL_UVM_PHASE_FINAL, u_ph_0, IVL_UVM_TOP_DOWN_PH);
  endtask : run_test

endpackage : ivl_uvm_pkg
import ivl_uvm_pkg::*;

`include "ivl_uvm_clp.svh"

// The below file is now part of user's file-list as last file
// `include "ivl_uvm_top.svh"
`endif //  IVL_UVM_PKG


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
  `define IVL_UVM_FACTORY // run-time test selection (no parameterized classes / Class:: on Icarus yet)
  `define UVM_CMDLINE_NO_DPI
`timescale 1ns/1ns

package ivl_uvm_pkg;
  `include "ivl_uvm_macros.svh"
  `include "ivl_uvm_types.svh"

  `include "ivl_uvm_patches.svh"
  `include "ivl_uvm_msg.svh"
  `include "base/uvm_misc.svh"
  `include "base/uvm_object.svh"
  `include "base/uvm_comparer.svh"
  `include "base/uvm_packer.svh"
  `include "base/uvm_printer.svh"
  `include "ivl_uvm_comps.svh"
  `include "base/ivl_uvm_factory.svh"
  `include "ivl_uvm_mbx.svh"
  `include "ivl_uvm_tlm.svh"

  uvm_component uvm_test_top;

  // Test selected at run time: run_test("name") or +UVM_TESTNAME=name; the
  // compile-time `UVM_TESTNAME (default uvm_test) is used when neither is given.
  task run_test (string test_name = "");
    string tn;
    if (test_name != "") tn = test_name;
    else if (!`IVL_UVM_VPA ("UVM_TESTNAME=%s", tn)) tn = `GO2UVM_DISP_ARG (`UVM_TESTNAME);
    `g2u_printf (( "Using UVM_TESTNAME: %s", tn ))
    m_ivl_init_factory();
    uvm_test_top = factory.create_component_by_name (tn, "", "uvm_test_top", null);
    if (uvm_test_top == null) begin
      uvm_report_fatal ("INVTST", $sformatf ("Requested test %s not found (not registered with `uvm_component_utils, or abstract like uvm_test?)", tn), UVM_NONE, `uvm_file, `uvm_line);
      return;
    end
    uvm_test_top.ivl_uvm_run_all_phases();
  endtask : run_test

endpackage : ivl_uvm_pkg
import ivl_uvm_pkg::*;

`include "ivl_uvm_clp.svh"

// The below file is now part of user's file-list as last file
// `include "ivl_uvm_top.svh"
`endif //  IVL_UVM_PKG


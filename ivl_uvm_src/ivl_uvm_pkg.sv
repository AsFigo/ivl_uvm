// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_pkg.sv
// Author(s): Anirudh Pradyumnan (apseng03@gmail.com)
//            Srinivasan Venkataramanan 
//
// Copyright (c) VerifWorks 2016-2020  All Rights Reserved.
// Contact us via: support@verifworks.com
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 3 as published by the Free Software Foundation.
// 
// This program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// 
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


// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_top.svh
// Authors: Srinivasan Venkataramanan, Ajeetha Kumari Venkatesan
// Copyright (c) 2026 AsFigo (https://www.asfigo.com)
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
module ivl_uvm_top;
  import ivl_uvm_pkg::*;

  /*
  `UVM_TESTNAME uvm_test_top;

  initial begin : m_top
    $timeformat (-9, 3, " ns", 3);
    `g2u_printf (( "Using UVM_TESTNAME: %s", `GO2UVM_DISP_ARG (`UVM_TESTNAME) ))
    uvm_test_top = new ("uvm_test_top", null);

  end : m_top
  */

  final begin
    report_summarize();
  end
endmodule : ivl_uvm_top


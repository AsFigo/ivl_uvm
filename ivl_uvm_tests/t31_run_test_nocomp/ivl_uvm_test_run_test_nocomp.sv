// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_run_test_nocomp.sv
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
// Test of run_test with no test name and no component: as in the BCL there is
// nothing to run, so run_test reports the fatal NOCOMP and the simulation ends.
// The log (compared with the golden log) must show that fatal and no
// "NOT REACHED" line.
module t_run_test_nocomp;
  import ivl_uvm_pkg::*;

  initial begin
    run_test();
    `uvm_info("NOCOMP_T", "NOT REACHED: FAIL  run_test returned without ending the run", UVM_NONE)
  end
endmodule : t_run_test_nocomp

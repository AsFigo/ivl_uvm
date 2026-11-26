// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_types.svh
// Author(s): Srinivasan Venkataramanan
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
`ifndef __IVL_UVM_TYPES__
`define __IVL_UVM_TYPES__

`include "base/uvm_object_globals.svh"


int uvm_info_counter;
int uvm_warn_counter;
int uvm_err_counter;
int uvm_fatal_counter;
int ivl_uvm_glb_verb;
bit report_summarize_done;

int unsigned ivl_uvm_max_quit_count = '1;

string log_id = "IVL_GO2UVM";

// The nine common phases, in the order run_test runs them. Used until the
// phase objects of the BCL are ported.
typedef enum {
  IVL_UVM_PHASE_BUILD,
  IVL_UVM_PHASE_CONNECT,
  IVL_UVM_PHASE_END_OF_ELABORATION,
  IVL_UVM_PHASE_START_OF_SIMULATION,
  IVL_UVM_PHASE_RUN,
  IVL_UVM_PHASE_EXTRACT,
  IVL_UVM_PHASE_CHECK,
  IVL_UVM_PHASE_REPORT,
  IVL_UVM_PHASE_FINAL
} ivl_uvm_phase_e;

// The direction in which the component tree is walked for a phase.
typedef enum {
  IVL_UVM_TOP_DOWN_PH,
  IVL_UVM_BOTTOM_UP_PH
} ivl_uvm_phase_dir_e;

`endif // __IVL_UVM_TYPES__


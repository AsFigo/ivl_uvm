// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_report_object.svh
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
`ifdef IVL_UVM
`ifndef IVL_UVM_REPORT_OBJECT_SVH
`define IVL_UVM_REPORT_OBJECT_SVH

// Stand-in for the BCL uvm_report_object: only the base of uvm_component and
// uvm_objection so far. The report handler is not ported yet.
class uvm_report_object extends uvm_object;
  // Creates the report object with the given name.
  extern function new (string name = "uvm_report_object");
endclass : uvm_report_object

function uvm_report_object::new (string name = "uvm_report_object");
  super.new (name);
endfunction : new

`endif // IVL_UVM_REPORT_OBJECT_SVH
`endif // IVL_UVM

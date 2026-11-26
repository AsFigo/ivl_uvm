// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_sequence_base.svh
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
`ifndef IVL_UVM_SEQUENCE_BASE_SVH
`define IVL_UVM_SEQUENCE_BASE_SVH

// Placeholder for the handle type of uvm_sequence_item. It carries no sequence
// behaviour yet; the sequence item only needs its name.
class uvm_sequence_base extends uvm_sequence_item;
  // Creates the sequence with the given name.
  extern function new (string name = "uvm_sequence");
endclass : uvm_sequence_base

function uvm_sequence_base::new (string name = "uvm_sequence");
  super.new (name);
endfunction : new

`endif // IVL_UVM_SEQUENCE_BASE_SVH
`endif // IVL_UVM

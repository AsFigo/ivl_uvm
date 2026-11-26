// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_sequencer_base.svh
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
`ifndef IVL_UVM_SEQUENCER_BASE_SVH
`define IVL_UVM_SEQUENCER_BASE_SVH

// Placeholder for the handle type of uvm_sequence_item. It carries no sequencer
// behaviour yet; the sequence item only needs its name and depth.
class uvm_sequencer_base extends uvm_component;
  // Creates the sequencer with the given name below parent.
  extern function new (string name,
                       uvm_component parent);
endclass : uvm_sequencer_base

function uvm_sequencer_base::new (string name,
                                  uvm_component parent);
  super.new (name, parent);
endfunction : new

`endif // IVL_UVM_SEQUENCER_BASE_SVH
`endif // IVL_UVM

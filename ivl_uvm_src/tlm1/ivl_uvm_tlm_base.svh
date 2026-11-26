// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_tlm_base.svh
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
`ifndef IVL_UVM_TLM_BASE_SVH
`define IVL_UVM_TLM_BASE_SVH

// Base of the TLM stand-ins: a component, until the BCL TLM ports are ported.
class ivl_uvm_tlm_base extends uvm_component;

  // Creates the TLM stand-in component.
  extern function new (string name = "ivl_uvm_tlm_base", uvm_component parent = null);
endclass : ivl_uvm_tlm_base

function ivl_uvm_tlm_base::new (string name = "ivl_uvm_tlm_base", uvm_component parent = null);
  super.new (name, parent);
endfunction : new

`endif // IVL_UVM_TLM_BASE_SVH

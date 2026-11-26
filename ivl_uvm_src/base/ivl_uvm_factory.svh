// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_factory.svh
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
`ifdef IVL_UVM
`ifndef IVL_UVM_FACTORY_SVH
`define IVL_UVM_FACTORY_SVH

// Minimal uvm_factory for current Icarus (no associative arrays or queues of
// handles in a class, so the registries are linked lists; type and instance
// overrides are not supported yet).
// Registry is a linked list of prototype objects, filled by the static
// initializers that `uvm_component_utils / `uvm_object_utils generate.
// User-facing API follows UVM: factory.create_component_by_name,
// factory.create_object_by_name, factory.print, run_test(), +UVM_TESTNAME.

`include "base/ivl_uvm_comp_node.svh"
`include "base/ivl_uvm_obj_node.svh"
`include "base/uvm_factory.svh"
`include "base/uvm_default_factory.svh"

// The package variables factory and m_ivl_factory are in ivl_uvm_pkg_globals.svh.

// Creates the factory on first use, so registration order across packages is irrelevant.
function void m_ivl_init_factory();
  if (m_ivl_factory == null) begin
    m_ivl_factory = new();
    factory = m_ivl_factory;
  end
endfunction : m_ivl_init_factory

// The factory, created on first use. An expression call, so that it can be made
// from a static method (Icarus rejects a function call statement there).
function uvm_factory m_ivl_get_factory();
  m_ivl_init_factory();
  return factory;
endfunction : m_ivl_get_factory

// Called by the static initializers of `uvm_component_utils / `uvm_object_utils.
function bit m_ivl_register_component(uvm_component proto);
  m_ivl_init_factory();
  m_ivl_factory.m_register_component(proto);
  return 1;
endfunction : m_ivl_register_component

function bit m_ivl_register_object(uvm_object proto);
  m_ivl_init_factory();
  m_ivl_factory.m_register_object(proto);
  return 1;
endfunction : m_ivl_register_object

`endif // IVL_UVM_FACTORY_SVH
`endif // IVL_UVM

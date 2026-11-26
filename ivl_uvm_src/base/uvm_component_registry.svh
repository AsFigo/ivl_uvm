// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_component_registry.svh
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
`ifndef IVL_UVM_COMPONENT_REGISTRY_SVH
`define IVL_UVM_COMPONENT_REGISTRY_SVH

// uvm_component_registry: the BCL class for uvm_component-based types. Same
// Icarus differences as uvm_object_registry (see uvm_registry.svh); create goes
// through the factory entry point create_component_by_type.
class uvm_component_registry #(type T) extends uvm_object_wrapper;
  typedef uvm_component_registry #(T) this_type;

  static this_type m_ivl_uvm_me;
  static string m_ivl_uvm_type_name = "<unknown>";

  // Creates a component of type T with the given name and parent.
  extern virtual function uvm_component create_component(string name,
                                                         uvm_component parent);

  // Returns the type name set by the utils macro ("<unknown>" without one).
  extern virtual function string get_type_name();

  // Returns the single registry object of this type, creating it on first use.
  extern static function uvm_component_registry #(T) get();

  // Called by the uvm_component_utils macros: sets the lookup name of the type.
  extern static function bit m_ivl_uvm_set_type_name(string name);

  // Internal: reports a fatal message (a static method cannot do it itself).
  extern function void m_ivl_uvm_fatal(string id,
                                       string msg);

  // Creates a component of type T through the factory, so overrides apply.
  extern static function T create(string name,
                                   uvm_component parent,
                                   string contxt = "");
endclass : uvm_component_registry

function uvm_component uvm_component_registry::create_component(string name,
                                                                uvm_component parent);
  T obj;
  obj = new(name, parent);
  return obj;
endfunction : create_component

function string uvm_component_registry::get_type_name();
  return m_ivl_uvm_type_name;
endfunction : get_type_name

function uvm_component_registry #(T) uvm_component_registry::get();
  if (m_ivl_uvm_me == null) begin
    m_ivl_uvm_me = new();
  end
  return m_ivl_uvm_me;
endfunction : get

function bit uvm_component_registry::m_ivl_uvm_set_type_name(string name);
  m_ivl_uvm_type_name = name;
  return 1;
endfunction : m_ivl_uvm_set_type_name

function void uvm_component_registry::m_ivl_uvm_fatal(string id,
                                                      string msg);
  uvm_report_fatal(id, msg, UVM_NONE);
endfunction : m_ivl_uvm_fatal

function T uvm_component_registry::create(string name,
                                                                     uvm_component parent,
                                                                     string contxt = "");
  uvm_component obj;
  T result;
  uvm_component_registry #(T) r;
  uvm_factory f;
  string msg;
  f = m_ivl_get_factory();
  if (contxt == "" && parent != null) begin
    contxt = parent.get_full_name();
  end
  r = get();
  obj = f.create_component_by_type(r, contxt, name, parent);
  if (!$cast(result, obj)) begin
    msg = {"Factory did not return a component of type '", m_ivl_uvm_type_name,
           "'. A component of type '", (obj == null) ? "null" : obj.get_type_name(),
           "' was returned instead. Name=", name,
           " Parent=", (parent == null) ? "null" : parent.get_type_name(),
           " contxt=", contxt};
    r.m_ivl_uvm_fatal("FCTTYP", msg);
  end
  return result;
endfunction : create

`endif // IVL_UVM_COMPONENT_REGISTRY_SVH
`endif // IVL_UVM

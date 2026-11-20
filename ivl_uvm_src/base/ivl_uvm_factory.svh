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
`ifdef IVL_UVM_FACTORY
`ifndef IVL_UVM_FACTORY_SVH
`define IVL_UVM_FACTORY_SVH

// Minimal uvm_factory for current Icarus (no associative arrays or queues of
// handles in a class, so the registries are linked lists; type and instance
// overrides are not supported yet).
// Registry is a linked list of prototype objects, filled by the static
// initializers that `uvm_component_utils / `uvm_object_utils generate.
// User-facing API follows UVM: factory.create_component_by_name,
// factory.create_object_by_name, factory.print, run_test(), +UVM_TESTNAME.

class ivl_uvm_comp_node;
  uvm_component proto;
  ivl_uvm_comp_node next;
endclass : ivl_uvm_comp_node

class ivl_uvm_obj_node;
  uvm_object proto;
  ivl_uvm_obj_node next;
endclass : ivl_uvm_obj_node

// Same split as the BCL: abstract uvm_factory with the public API as virtual
// methods, uvm_default_factory implements it (extern virtual); m_* helpers are not virtual.
// The BCL declares the API `pure virtual`; Icarus does not support that yet, so the
// base methods have trivial bodies instead.
virtual class uvm_factory;
  virtual function uvm_component create_component_by_name(string requested_type_name,
                                                          string parent_inst_path = "",
                                                          string name,
                                                          uvm_component parent);
    return null;
  endfunction : create_component_by_name

  virtual function uvm_object create_object_by_name(string requested_type_name,
                                                    string parent_inst_path = "",
                                                    string name = "");
    return null;
  endfunction : create_object_by_name

  virtual function uvm_object create_object_by_type(uvm_object_wrapper requested_type,
                                                    string parent_inst_path = "",
                                                    string name = "");
    return null;
  endfunction : create_object_by_type

  virtual function bit is_type_name_registered(string type_name);
    return 0;
  endfunction : is_type_name_registered

  virtual function void print(int all_types = 1);
    // keep the body non-empty: Icarus skips overrides when the base body is empty
    return;
  endfunction : print
endclass : uvm_factory

class uvm_default_factory extends uvm_factory;
  ivl_uvm_comp_node m_comps;
  ivl_uvm_obj_node  m_objs;

  extern function void m_register_component(uvm_component proto);
  extern function void m_register_object(uvm_object proto);
  extern virtual function uvm_component create_component_by_name(string requested_type_name,
                                                                 string parent_inst_path = "",
                                                                 string name,
                                                                 uvm_component parent);
  extern virtual function uvm_object create_object_by_name(string requested_type_name,
                                                           string parent_inst_path = "",
                                                           string name = "");
  extern virtual function uvm_object create_object_by_type(uvm_object_wrapper requested_type,
                                                           string parent_inst_path = "",
                                                           string name = "");
  extern virtual function bit is_type_name_registered(string type_name);
  extern virtual function void print(int all_types = 1);
  extern function bit m_is_uvm_type(string type_name);
endclass : uvm_default_factory

function void uvm_default_factory::m_register_component(uvm_component proto);
  ivl_uvm_comp_node n;
  n = new();
  n.proto = proto;
  n.next = m_comps;
  m_comps = n;
endfunction : m_register_component

function void uvm_default_factory::m_register_object(uvm_object proto);
  ivl_uvm_obj_node n;
  n = new();
  n.proto = proto;
  n.next = m_objs;
  m_objs = n;
endfunction : m_register_object

function bit uvm_default_factory::is_type_name_registered(string type_name);
  ivl_uvm_comp_node c;
  ivl_uvm_obj_node  o;
  for (c = m_comps; c != null; c = c.next) begin
    if (c.proto.get_type_name() == type_name) begin
      return 1;
    end
  end
  for (o = m_objs; o != null; o = o.next) begin
    if (o.proto.get_type_name() == type_name) begin
      return 1;
    end
  end
  return 0;
endfunction : is_type_name_registered

function uvm_component uvm_default_factory::create_component_by_name(string requested_type_name,
                                                                     string parent_inst_path = "",
                                                                     string name,
                                                                     uvm_component parent);
  ivl_uvm_comp_node it;
  for (it = m_comps; it != null; it = it.next) begin
    if (it.proto.get_type_name() == requested_type_name) begin
      return it.proto.m_ivl_create_component(name, parent);
    end
  end
  return null;
endfunction : create_component_by_name

function uvm_object uvm_default_factory::create_object_by_name(string requested_type_name,
                                                               string parent_inst_path = "",
                                                               string name = "");
  ivl_uvm_obj_node it;
  for (it = m_objs; it != null; it = it.next) begin
    if (it.proto.get_type_name() == requested_type_name) begin
      return it.proto.create(name);
    end
  end
  return null;
endfunction : create_object_by_name

// No overrides yet, so the requested type is the type created.
function uvm_object uvm_default_factory::create_object_by_type(uvm_object_wrapper requested_type,
                                                               string parent_inst_path = "",
                                                               string name = "");
  if (requested_type == null) begin
    return null;
  end
  return requested_type.create_object(name);
endfunction : create_object_by_type

function bit uvm_default_factory::m_is_uvm_type(string type_name);
  return (type_name.len() >= 4 && type_name.substr(0, 3) == "uvm_");
endfunction : m_is_uvm_type

function void uvm_default_factory::print(int all_types = 1);
  ivl_uvm_comp_node c;
  ivl_uvm_obj_node  o;
  string qs;
  string tn;
  int    n;
  bit    banner;

  qs = "\n#### Factory Configuration (*)\n\n";
  // overrides are not supported in IVL_UVM yet
  qs = {qs, "  No instance or type overrides are registered with this factory\n"};

  // print all registered types, if all_types >= 1
  if (all_types >= 1) begin
    for (c = m_comps; c != null; c = c.next) n++;
    for (o = m_objs; o != null; o = o.next) n++;
    qs = {qs, $sformatf("\nAll types registered with the factory: %0d total\n", n)};
    for (c = m_comps; c != null; c = c.next) begin
      tn = c.proto.get_type_name();
      if (all_types >= 2 || !m_is_uvm_type(tn)) begin
        if (!banner) begin
          qs = {qs, "  Type Name\n  ---------\n"};
          banner = 1;
        end
        qs = {qs, $sformatf("  %s\n", tn)};
      end
    end
    for (o = m_objs; o != null; o = o.next) begin
      tn = o.proto.get_type_name();
      if (all_types >= 2 || !m_is_uvm_type(tn)) begin
        if (!banner) begin
          qs = {qs, "  Type Name\n  ---------\n"};
          banner = 1;
        end
        qs = {qs, $sformatf("  %s\n", tn)};
      end
    end
  end

  qs = {qs, "(*) Types with no associated type name will be printed as <unknown>\n\n####\n\n"};
  `uvm_info("UVM/FACTORY/PRINT", qs, UVM_NONE)
endfunction : print

uvm_factory         factory;       // as used by the rest of the BCL
uvm_default_factory m_ivl_factory; // same object, typed for registration

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
`endif // IVL_UVM_FACTORY

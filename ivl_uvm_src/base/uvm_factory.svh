// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_factory.svh
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
`ifndef IVL_UVM_FACTORY_CLASS_SVH
`define IVL_UVM_FACTORY_CLASS_SVH

// Same split as the BCL: abstract uvm_factory with the public API as virtual
// methods, uvm_default_factory implements it (extern virtual); m_* helpers are not virtual.
// The BCL declares the API `pure virtual`; Icarus does not support that yet, so the
// base methods have trivial bodies instead.
virtual class uvm_factory;

  // Creates a component of the registered type name (the base class returns null).
  extern virtual function uvm_component create_component_by_name(string requested_type_name,
                                                                 string parent_inst_path = "",
                                                                 string name,
                                                                 uvm_component parent);

  // Creates an object of the registered type name (the base class returns null).
  extern virtual function uvm_object create_object_by_name(string requested_type_name,
                                                           string parent_inst_path = "",
                                                           string name = "");

  // Creates a component of the wrapper's type (the base class returns null).
  extern virtual function uvm_component create_component_by_type(uvm_object_wrapper requested_type,
                                                                 string parent_inst_path = "",
                                                                 string name,
                                                                 uvm_component parent);

  // Creates an object of the wrapper's type (the base class returns null).
  extern virtual function uvm_object create_object_by_type(uvm_object_wrapper requested_type,
                                                           string parent_inst_path = "",
                                                           string name = "");

  // Returns 1 if a type with this name is registered (the base class returns 0).
  extern virtual function bit is_type_name_registered(string type_name);

  // Prints the factory contents (the base class does nothing).
  extern virtual function void print(int all_types = 1);
endclass : uvm_factory

function uvm_component uvm_factory::create_component_by_name(string requested_type_name,
                                                             string parent_inst_path = "",
                                                             string name,
                                                             uvm_component parent);
  return null;
endfunction : create_component_by_name

function uvm_object uvm_factory::create_object_by_name(string requested_type_name,
                                                       string parent_inst_path = "",
                                                       string name = "");
  return null;
endfunction : create_object_by_name

function uvm_component uvm_factory::create_component_by_type(uvm_object_wrapper requested_type,
                                                             string parent_inst_path = "",
                                                             string name,
                                                             uvm_component parent);
  return null;
endfunction : create_component_by_type

function uvm_object uvm_factory::create_object_by_type(uvm_object_wrapper requested_type,
                                                       string parent_inst_path = "",
                                                       string name = "");
  return null;
endfunction : create_object_by_type

function bit uvm_factory::is_type_name_registered(string type_name);
  return 0;
endfunction : is_type_name_registered

function void uvm_factory::print(int all_types = 1);
  // keep the body non-empty: Icarus skips overrides when the base body is empty
  return;
endfunction : print

`endif // IVL_UVM_FACTORY_CLASS_SVH
`endif // IVL_UVM

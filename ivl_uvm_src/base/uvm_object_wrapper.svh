// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_object_wrapper.svh
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
`ifndef IVL_UVM_OBJECT_WRAPPER_SVH
`define IVL_UVM_OBJECT_WRAPPER_SVH

// The base class of the factory wrappers (uvm_object_registry,
// uvm_component_registry). The BCL declares the three methods pure virtual;
// Icarus does not support that yet, so the base methods have trivial bodies
// (and every method keeps a body, because Icarus skips overrides when the base
// body is empty).
virtual class uvm_object_wrapper;
  // Creates an object of the wrapped type (the base class returns null).
  extern virtual function uvm_object create_object (string name = "");

  // Creates a component of the wrapped type (the base class returns null).
  extern virtual function uvm_component create_component (string name,
                                                          uvm_component parent);

  // Returns the type name of the wrapped type (the base class "<unknown>").
  extern virtual function string get_type_name();
endclass : uvm_object_wrapper

function uvm_object uvm_object_wrapper::create_object (string name = "");
  return null;
endfunction : create_object

function uvm_component uvm_object_wrapper::create_component (string name,
                                                             uvm_component parent);
  return null;
endfunction : create_component

function string uvm_object_wrapper::get_type_name();
  return "<unknown>";
endfunction : get_type_name

`endif // IVL_UVM_OBJECT_WRAPPER_SVH
`endif // IVL_UVM

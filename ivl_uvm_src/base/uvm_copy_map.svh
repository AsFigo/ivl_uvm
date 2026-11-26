// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_copy_map.svh
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
`ifndef IVL_UVM_COPY_MAP_SVH
`define IVL_UVM_COPY_MAP_SVH

// uvm_copy_map: the BCL class keys an associative array by object handle,
// which Icarus does not support, so it keeps the same API on a linked list.
`include "base/ivl_uvm_ll_node.svh"
`include "base/ivl_uvm_linked_list.svh"
`include "base/ivl_uvm_string_list.svh"

class uvm_copy_map;
  local ivl_uvm_linked_list #(uvm_object, uvm_object) m_ivl_uvm_map;

  // Creates an empty map.
  extern function new();

  // Maps key to obj, replacing an earlier entry for key.
  extern function void set(uvm_object key, uvm_object obj);

  // Returns the object mapped to key, or null.
  extern function uvm_object get(uvm_object key);

  // Removes every entry.
  extern function void clear();

  // Removes the entry for v, if present.
  extern function void delete(uvm_object v);
endclass : uvm_copy_map

function uvm_copy_map::new();
  m_ivl_uvm_map = new;
endfunction : new

function void uvm_copy_map::set(uvm_object key, uvm_object obj);
  m_ivl_uvm_map.set(key, obj);
endfunction : set

function uvm_object uvm_copy_map::get(uvm_object key);
  ivl_uvm_ll_node #(uvm_object, uvm_object) n;
  n = m_ivl_uvm_map.find_node(key);
  if (n == null) begin
    return null;
  end
  return n.val;
endfunction : get

function void uvm_copy_map::clear();
  m_ivl_uvm_map.clear();
endfunction : clear

function void uvm_copy_map::delete(uvm_object v);
  m_ivl_uvm_map.remove_key(v);
endfunction : delete

`endif // IVL_UVM_COPY_MAP_SVH
`endif // IVL_UVM

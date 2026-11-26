// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_string_list.svh
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
`ifndef IVL_UVM_STRING_LIST_SVH
`define IVL_UVM_STRING_LIST_SVH

// String-keyed list that keeps its keys in ascending order (the order a BCL
// associative array indexed by string is iterated in). A separate class
// because Icarus rejects < on the key in the generic list when K is a class.
class ivl_uvm_string_list #(type V) extends ivl_uvm_linked_list #(string, V);
  // Creates an empty list.
  extern function new();

  // Adds key/val in key order, or replaces the value when the key is present.
  // Use it for every key of a list, never mixed with set.
  extern virtual function void set_sorted(string key, V val);
endclass : ivl_uvm_string_list

function ivl_uvm_string_list::new();
  super.new();
endfunction : new

function void ivl_uvm_string_list::set_sorted(string key, V val);
  ivl_uvm_ll_node #(string, V) n;
  ivl_uvm_ll_node #(string, V) prev;
  ivl_uvm_ll_node #(string, V) cur;
  n = this.find_node(key);
  if (n != null) begin
    n.val = val;
    return;
  end
  n = new;
  n.key = key;
  n.val = val;
  prev = null;
  cur = m_ivl_uvm_head;
  while (cur != null) begin
    if (!(cur.key < key)) begin
      break;
    end
    prev = cur;
    cur = cur.next;
  end
  n.next = cur;
  if (prev == null) begin
    m_ivl_uvm_head = n;
  end
  else begin
    prev.next = n;
  end
  m_ivl_uvm_size++;
endfunction : set_sorted

`endif // IVL_UVM_STRING_LIST_SVH
`endif // IVL_UVM

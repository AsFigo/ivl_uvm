// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_linked_list.svh
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
`ifndef IVL_UVM_LINKED_LIST_SVH
`define IVL_UVM_LINKED_LIST_SVH

// Key/value map kept as a singly linked list. Stands in for an associative
// array keyed by class handle, which Icarus does not support yet (assoc arrays,
// queues and dynamic arrays of class handles). Keys are compared with ==
// (handle identity for class types).
//
// K and V have no default type on purpose: a default would make Icarus
// elaborate a default specialization. Use ivl_uvm_linked_list #(K, V).
//
// Notes for Icarus: a member of a class-handle property (head.next) is not
// supported, so handles are copied to locals before the member is selected.

class ivl_uvm_ll_node #(type K, type V);
  K key;
  V val;
  ivl_uvm_ll_node #(K, V) next;
endclass : ivl_uvm_ll_node

class ivl_uvm_linked_list #(type K, type V);
  local ivl_uvm_ll_node #(K, V) m_ivl_uvm_head;
  local int m_ivl_uvm_size;

  extern function new();

  // Returns the node holding key, or null when the key is not in the list.
  // Defined inline: Icarus cannot parse an out-of-body definition whose return
  // type is a parameterized class.
  function ivl_uvm_ll_node #(K, V) find_node(K key);
    ivl_uvm_ll_node #(K, V) n;
    n = m_ivl_uvm_head;
    while (n != null) begin
      if (n.key == key) begin
        return n;
      end
      n = n.next;
    end
    return null;
  endfunction : find_node

  // Returns the node added last (the head), or null when the list is empty.
  // Defined inline for the same reason as find_node.
  function ivl_uvm_ll_node #(K, V) first_node();
    return m_ivl_uvm_head;
  endfunction : first_node

  // Adds key/val, or replaces the value when the key is already present.
  extern function void set(K key, V val);

  // Removes the entry for key; does nothing when the key is not present.
  extern function void remove_key(K key);

  extern function void clear();

  extern function int size();
endclass : ivl_uvm_linked_list

function ivl_uvm_linked_list::new();
  m_ivl_uvm_head = null;
  m_ivl_uvm_size = 0;
endfunction : new

function void ivl_uvm_linked_list::set(K key, V val);
  ivl_uvm_ll_node #(K, V) n;
  n = find_node(key);
  if (n != null) begin
    n.val = val;
    return;
  end
  n = new;
  n.key = key;
  n.val = val;
  n.next = m_ivl_uvm_head;
  m_ivl_uvm_head = n;
  m_ivl_uvm_size++;
endfunction : set

function void ivl_uvm_linked_list::remove_key(K key);
  ivl_uvm_ll_node #(K, V) n;
  ivl_uvm_ll_node #(K, V) prev;
  n = m_ivl_uvm_head;
  prev = null;
  while (n != null) begin
    if (n.key == key) begin
      if (prev == null) begin
        m_ivl_uvm_head = n.next;
      end
      else begin
        prev.next = n.next;
      end
      m_ivl_uvm_size--;
      return;
    end
    prev = n;
    n = n.next;
  end
endfunction : remove_key

function void ivl_uvm_linked_list::clear();
  m_ivl_uvm_head = null;
  m_ivl_uvm_size = 0;
endfunction : clear

function int ivl_uvm_linked_list::size();
  return m_ivl_uvm_size;
endfunction : size

`endif // IVL_UVM_LINKED_LIST_SVH
`endif // IVL_UVM

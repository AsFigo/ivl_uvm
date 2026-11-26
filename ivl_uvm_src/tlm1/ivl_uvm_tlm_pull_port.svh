// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_tlm_pull_port.svh
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
`ifndef IVL_UVM_TLM_PULL_PORT_SVH
`define IVL_UVM_TLM_PULL_PORT_SVH

// Stand-in for a pull port with a single-entry buffer (see ivl_uvm_mbx).
class ivl_uvm_tlm_pull_port extends ivl_uvm_tlm_base;
    bit is_full;
    bit is_empty;
    int m_size;
    `IVL_UVM_MBX_T m_mbx_val;

  // Creates an empty one-entry port.
  extern function new (string name = "ivl_uvm_tlm_pull_port", uvm_component parent = null);

  // Blocks while the port is full, then stores in_xn.
  extern virtual task put (input `IVL_UVM_MBX_T in_xn);

  // Blocks while the port is empty, then returns and removes the value.
  extern virtual task get (output `IVL_UVM_MBX_T out_xn);
  
    // TODO: placeholder. try_get does not fill its argument or return a
    // status yet (the TLM ports are not ported); only item_done relies on it.

  // Placeholder: removes the value when present (the argument is not filled yet).
  extern virtual function bit try_get (`IVL_UVM_MBX_T out_xn);

  // Blocks while the port is empty, then returns the value without removing it.
  extern virtual task peek (output `IVL_UVM_MBX_T out_xn);

  // Returns 1 when the port holds a value, else 0.
  extern virtual function int num ();

  // Connects to an export (nothing to do for the stand-in).
  extern virtual function void connect (ivl_uvm_tlm_pull_export unused_tlm_exp);

  // Blocks until an item is available and returns it without removing it.
  extern virtual task get_next_item (output `IVL_UVM_MBX_T x0);

  // Removes the item returned by get_next_item.
  extern virtual function void item_done ();
  
endclass : ivl_uvm_tlm_pull_port

function ivl_uvm_tlm_pull_port::new (string name = "ivl_uvm_tlm_pull_port", uvm_component parent = null);
  super.new (name, parent);
  is_full = 0;
  is_empty = 1;
endfunction : new

task ivl_uvm_tlm_pull_port::put (input `IVL_UVM_MBX_T in_xn);
  //wait (is_full == 0);
  while (is_full == 1) begin
    #1;
  end
  m_mbx_val = in_xn;
  `g2u_printf (("%m Put: "))
  is_full = 1;
  is_empty = 0;
endtask : put

task ivl_uvm_tlm_pull_port::get (output `IVL_UVM_MBX_T out_xn);
  //wait (is_empty == 0);
  while (is_empty == 1) begin
    #1;
  end
  out_xn = m_mbx_val;
  is_full = 0;
  is_empty = 1;
  `g2u_printf (("%m Get: "))
endtask : get

function bit ivl_uvm_tlm_pull_port::try_get (`IVL_UVM_MBX_T out_xn);
   bit rval;
   if (is_empty == 0) begin
     is_full = 0;
     is_empty = 1;
     out_xn = m_mbx_val;
     rval = 1;
   end
endfunction : try_get

task ivl_uvm_tlm_pull_port::peek (output `IVL_UVM_MBX_T out_xn);
  //wait (is_empty == 0);
  while (is_empty == 1) begin
    #1;
  end
  out_xn = m_mbx_val;
  `g2u_printf (("%m Peek: "))
endtask : peek

function int ivl_uvm_tlm_pull_port::num ();
  return (is_full);
endfunction : num

function void ivl_uvm_tlm_pull_port::connect (ivl_uvm_tlm_pull_export unused_tlm_exp);
endfunction : connect

task ivl_uvm_tlm_pull_port::get_next_item (output `IVL_UVM_MBX_T x0);
  `g2u_printf (("%m get_next_item: "))
  peek(x0);
endtask : get_next_item

function void ivl_uvm_tlm_pull_port::item_done ();
  bit rval;
  `IVL_UVM_MBX_T x0;
  rval = try_get(x0);
endfunction : item_done

`endif // IVL_UVM_TLM_PULL_PORT_SVH

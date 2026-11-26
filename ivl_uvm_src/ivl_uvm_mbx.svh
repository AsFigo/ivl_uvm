// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_mbx.svh
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

`ifndef IVL_UVM_MBX_T 
  `define IVL_UVM_MBX_T int
`endif

// Poor man's mailbox
// Default size = 1 in SV
// Here, only size-1 is supported as of now
// The element type is fixed by a `define (a parameterized mailbox class is a
// later step)
//
// Only one type of mailbox is supported as of now
//
class ivl_uvm_mbx extends uvm_object;
  bit is_full;
  bit is_empty;
  int m_size;
  `IVL_UVM_MBX_T m_mbx_val;

  // Creates an empty mailbox.
  extern function new (string name = "mailbox_int");

  // Blocks while the mailbox is full, then stores in_xn.
  extern virtual task put (input `IVL_UVM_MBX_T in_xn);

  // Blocks while the mailbox is empty, then returns and removes the value.
  extern virtual task get (output `IVL_UVM_MBX_T out_xn);

  // Blocks while the mailbox is empty, then returns the value without removing it.
  extern virtual task peek (output `IVL_UVM_MBX_T out_xn);

  // Returns 1 when the mailbox holds a value, else 0.
  extern virtual function int num ();


endclass : ivl_uvm_mbx

function ivl_uvm_mbx::new (string name = "mailbox_int");
  super.new (name);
  is_full = 0;
  is_empty = 1;
endfunction : new

task ivl_uvm_mbx::put (input `IVL_UVM_MBX_T in_xn);
  //wait (is_full == 0);
  while (is_full == 1) begin
    #1;
  end
  m_mbx_val = in_xn;
  //`g2u_printf (("MBX: Put: 0x%0h", in_xn))
  is_full = 1;
  is_empty = 0;
endtask : put

task ivl_uvm_mbx::get (output `IVL_UVM_MBX_T out_xn);
  //wait (is_empty == 0);
  while (is_empty == 1) begin
    #1;
  end
  out_xn = m_mbx_val;
  //`g2u_printf (("MBX: Get: 0x%0h", out_xn))
  is_full = 0;
  is_empty = 1;
endtask : get

task ivl_uvm_mbx::peek (output `IVL_UVM_MBX_T out_xn);
  //wait (is_empty == 0);
  while (is_empty == 1) begin
    #1;
  end
  out_xn = m_mbx_val;
  //`g2u_printf (("MBX: Peek: 0x%0h", out_xn))
endtask : peek

function int ivl_uvm_mbx::num ();
  return (is_full);
endfunction : num



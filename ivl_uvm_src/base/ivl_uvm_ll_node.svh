// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_ll_node.svh
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
`ifndef IVL_UVM_LL_NODE_SVH
`define IVL_UVM_LL_NODE_SVH

// One entry of ivl_uvm_linked_list: key, value and the next entry. K and V have
// no default type on purpose: a default would make Icarus elaborate a default
// specialization.
class ivl_uvm_ll_node #(type K, type V);
  K key;
  V val;
  ivl_uvm_ll_node #(K, V) next;
endclass : ivl_uvm_ll_node

`endif // IVL_UVM_LL_NODE_SVH
`endif // IVL_UVM

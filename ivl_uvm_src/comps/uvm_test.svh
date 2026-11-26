// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_test.svh
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
`ifndef IVL_UVM_TEST_SVH
`define IVL_UVM_TEST_SVH

// The abstract base class of all tests (the BCL uvm_test adds nothing else).
virtual class uvm_test extends uvm_component;
  // Creates the test with the given name below parent.
  extern function new (string name = "uvm_test",
                       uvm_component parent = null);
endclass : uvm_test

function uvm_test::new (string name = "uvm_test",
                        uvm_component parent = null);
  super.new (name, parent);
  `g2u_display ("%m");
endfunction : new

`endif // IVL_UVM_TEST_SVH
`endif // IVL_UVM

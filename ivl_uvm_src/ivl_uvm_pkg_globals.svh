// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_pkg_globals.svh
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
`ifndef IVL_UVM_PKG_GLOBALS_SVH
`define IVL_UVM_PKG_GLOBALS_SVH

// Package-level variables only (no methods) that stand in for a class member
// or for root-component state the BCL keeps and that Icarus cannot hold there
// yet. They live in this one file, included after the linked list and before
// the classes that use them. Each one names what it stands in for and goes
// away when the BCL form works.

// Triggered on every change of any objection total (used by uvm_objection and
// by run_test). Icarus has no event members in a class and no wait on a class
// property; a waiter rechecks its own total each time.
event m_ivl_uvm_objection_changed;

// Triggered when uvm_top.set_timeout changes the global timeout, so the timer in
// the command line processor module re-reads it (a class member cannot be
// waited on, see above).
event m_ivl_uvm_timeout_changed;

// The BCL global uvm_top (a const initialised with uvm_root::get()). Assigned
// by uvm_root::get() on its first call; the package creates the root when it
// is elaborated (see ivl_uvm_pkg.sv).
uvm_root uvm_top;

// The BCL global factory handle, and the same object typed for the
// registration (the BCL keeps it in the singleton wrapper of uvm_factory). Both
// are created on first use by m_ivl_init_factory (base/ivl_uvm_factory.svh).
typedef class uvm_factory;
typedef class uvm_default_factory;
uvm_factory         factory;
uvm_default_factory m_ivl_factory;

`endif // IVL_UVM_PKG_GLOBALS_SVH
`endif // IVL_UVM

// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_status_container.svh
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
`ifndef IVL_UVM_STATUS_CONTAINER_SVH
`define IVL_UVM_STATUS_CONTAINER_SVH

// uvm_status_container: the BCL class with its three containers (static
// field_array[string], cycle_check[uvm_object], m_uvm_cycle_scopes[$] of
// handles) kept in linked lists, because Icarus does not support those yet.
class uvm_status_container;
  bit             clone = 1;

  bit          warning;
  bit          status;
  uvm_bitstream_t  bitstream;
  int          intv;
  int          element;
  string       stringv;
  string       scratch1;
  string       scratch2;
  string       key;
  uvm_object   object;
  bit          array_warning_done;

  static ivl_uvm_linked_list #(string, bit) field_array = new;

  static bit print_matches;

  uvm_scope_stack scope  = new;

  // Used for checking cycles (see the BCL): the objects seen so far.
  ivl_uvm_linked_list #(uvm_object, bit) cycle_check = new;

  uvm_comparer    comparer;
  uvm_packer      packer;
  uvm_recorder    recorder;
  uvm_printer     printer;

  // The scopes of the current call stack, newest first.
  ivl_uvm_linked_list #(uvm_object, bit) m_uvm_cycle_scopes = new;

  // Records field as seen (reports an error on a repeat when UVM_ENABLE_FIELD_CHECKS is set).
  extern function void do_field_check(string field, uvm_object obj);

  // Returns the name of the automation operation (copy, compare, ...) for what.
  extern function string get_function_type(int what);

  // Returns the current full scope with the argument.
  extern function string get_full_scope_arg();

  // Internal: returns 1 when scope is already on the call stack (a cycle).
  extern function bit m_do_cycle_check(uvm_object scope);
endclass : uvm_status_container

function void uvm_status_container::do_field_check(string field, uvm_object obj);
  `ifdef UVM_ENABLE_FIELD_CHECKS
  ivl_uvm_ll_node #(string, bit) n;
  n = field_array.find_node(field);
  if (n != null) begin
    uvm_report_error("MLTFLD", $sformatf("Field %s is defined multiple times in type '%s'",
       field, obj.get_type_name()), UVM_NONE);
  end
  `endif
  field_array.set(field, 1);
endfunction : do_field_check

function string uvm_status_container::get_function_type(int what);
  case (what)
    UVM_COPY:    return "copy";
    UVM_COMPARE: return "compare";
    UVM_PRINT:   return "print";
    UVM_RECORD:  return "record";
    UVM_PACK:    return "pack";
    UVM_UNPACK:  return "unpack";
    UVM_FLAGS:   return "get_flags";
    UVM_SETINT:  return "set";
    UVM_SETOBJ:  return "set_object";
    UVM_SETSTR:  return "set_string";
    default:     return "unknown";
  endcase
endfunction : get_function_type

function string uvm_status_container::get_full_scope_arg();
  get_full_scope_arg = scope.get();
endfunction : get_full_scope_arg

// Same logic as the BCL: it is a cycle only when the scope is not the one
// entered last AND it is already in the list of scopes.
function bit uvm_status_container::m_do_cycle_check(uvm_object scope);
  ivl_uvm_ll_node #(uvm_object, bit) last;
  ivl_uvm_ll_node #(uvm_object, bit) found;
  uvm_object l;
  last = m_uvm_cycle_scopes.first_node();
  l = null;
  if (last != null) begin
    l = last.key;
  end
  if (l == scope) begin
    // right before (a super/derived context of the same object): not a cycle
    return 0;
  end
  found = m_uvm_cycle_scopes.find_node(scope);
  if (found != null) begin
    return 1;
  end
  m_uvm_cycle_scopes.set(scope, 1);
  return 0;
endfunction : m_do_cycle_check

`endif // IVL_UVM_STATUS_CONTAINER_SVH
`endif // IVL_UVM

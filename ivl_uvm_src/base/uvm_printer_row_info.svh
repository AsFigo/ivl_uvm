// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_printer_row_info.svh
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
`ifndef IVL_UVM_PRINTER_ROW_INFO_SVH
`define IVL_UVM_PRINTER_ROW_INFO_SVH

class uvm_printer_row_info;
  int    level;
  string name;
  string type_name;
  string size;
  string val;
  // the next row of the printer
  uvm_printer_row_info m_ivl_uvm_next;
endclass : uvm_printer_row_info

`endif // IVL_UVM_PRINTER_ROW_INFO_SVH
`endif // IVL_UVM

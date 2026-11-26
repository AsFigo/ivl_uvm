// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_table_printer.svh
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
`ifndef IVL_UVM_TABLE_PRINTER_SVH
`define IVL_UVM_TABLE_PRINTER_SVH

class uvm_table_printer extends uvm_printer;

  // Creates a table printer.
  extern function new();

  // Returns the table: the header, one line per row, the footer.
  extern virtual function string emit();

  protected int m_max_name;
  protected int m_max_type;
  protected int m_max_size;
  protected int m_max_value;

  // Sets the column widths from the widest name, type, size and value.
  extern function void calculate_max_widths();

endclass : uvm_table_printer

// uvm_table_printer
// -----------------

function uvm_table_printer::new();
  super.new();
endfunction : new

function void uvm_table_printer::calculate_max_widths();
  uvm_printer_row_info row;
  int name_len;
  int type_len;
  int size_len;
  int val_len;
  string nm;
  string ty;
  string sz;
  string vl;
  uvm_printer_knobs kn;
  kn = knobs;
  m_max_name = 4;
  m_max_type = 4;
  m_max_size = 4;
  m_max_value = 5;
  row = m_rows;
  while (row != null) begin
    nm = row.name;
    ty = row.type_name;
    sz = row.size;
    vl = row.val;
    name_len = nm.len();
    type_len = ty.len();
    size_len = sz.len();
    val_len = vl.len();
    name_len = kn.indent * row.level + name_len;
    if (name_len > m_max_name) begin
      m_max_name = name_len;
    end
    if (type_len > m_max_type) begin
      m_max_type = type_len;
    end
    if (size_len > m_max_size) begin
      m_max_size = size_len;
    end
    if (val_len > m_max_value) begin
      m_max_value = val_len;
    end
    row = row.m_ivl_uvm_next;
  end
endfunction : calculate_max_widths

function string uvm_table_printer::emit();
  string s;
  string user_format;
  string dashes;
  string header;
  string row_str;
  string linefeed;
  string nm;
  string ty;
  string sz;
  string vl;
  uvm_printer_row_info row;
  uvm_printer_knobs kn;
  kn = knobs;
  s = "";
  dashes = "";
  linefeed = {"\n", kn.prefix};

  this.calculate_max_widths();

  if (kn.header) begin
    user_format = this.format_header();
    if (user_format == "") begin
      header = "";
      if (kn.identifier) begin
        dashes = this.m_ivl_uvm_pad("-", m_max_name + 2);
        header = {"Name", this.m_ivl_uvm_pad(" ", m_max_name - 2)};
      end
      if (kn.type_name) begin
        dashes = {dashes, this.m_ivl_uvm_pad("-", m_max_type + 2)};
        header = {header, "Type", this.m_ivl_uvm_pad(" ", m_max_type - 2)};
      end
      if (kn.size) begin
        dashes = {dashes, this.m_ivl_uvm_pad("-", m_max_size + 2)};
        header = {header, "Size", this.m_ivl_uvm_pad(" ", m_max_size - 2)};
      end
      dashes = {dashes, this.m_ivl_uvm_pad("-", m_max_value), linefeed};
      header = {header, "Value", this.m_ivl_uvm_pad(" ", m_max_value - 5), linefeed};
      s = {s, dashes, header, dashes};
    end
    else begin
      s = {s, user_format, linefeed};
    end
  end

  row = m_rows;
  while (row != null) begin
    nm = row.name;
    ty = row.type_name;
    sz = row.size;
    vl = row.val;
    user_format = this.format_row(row);
    if (user_format == "") begin
      row_str = "";
      if (kn.identifier) begin
        row_str = {this.m_ivl_uvm_pad(" ", row.level * kn.indent), nm,
                   this.m_ivl_uvm_pad(" ", m_max_name - nm.len() - (row.level * kn.indent) + 2)};
      end
      if (kn.type_name) begin
        row_str = {row_str, ty, this.m_ivl_uvm_pad(" ", m_max_type - ty.len() + 2)};
      end
      if (kn.size) begin
        row_str = {row_str, sz, this.m_ivl_uvm_pad(" ", m_max_size - sz.len() + 2)};
      end
      s = {s, row_str, vl, this.m_ivl_uvm_pad(" ", m_max_value - vl.len()), linefeed};
    end
    else begin
      s = {s, user_format, linefeed};
    end
    row = row.m_ivl_uvm_next;
  end

  if (kn.footer) begin
    user_format = this.format_footer();
    if (user_format == "") begin
      s = {s, dashes};
    end
    else begin
      s = {s, user_format, linefeed};
    end
  end

  m_rows = null;
  m_ivl_uvm_last_row = null;
  return s;
endfunction : emit

`endif // IVL_UVM_TABLE_PRINTER_SVH
`endif // IVL_UVM

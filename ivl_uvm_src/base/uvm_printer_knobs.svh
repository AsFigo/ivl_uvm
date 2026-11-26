// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_printer_knobs.svh
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
`ifndef IVL_UVM_PRINTER_KNOBS_SVH
`define IVL_UVM_PRINTER_KNOBS_SVH

class uvm_printer_knobs;

  bit header = 1;
  bit footer = 1;
  bit full_name = 0;
  bit identifier = 1;
  bit type_name = 1;
  bit size = 1;
  int depth = -1;
  bit reference = 1;
  int begin_elements = 5;
  int end_elements = 5;
  string prefix = "";
  int indent = 2;
  bit show_root = 0;
  int mcd = UVM_STDOUT;
  string separator = "{}";
  bit show_radix = 1;
  uvm_radix_enum default_radix = UVM_HEX;
  string dec_radix = "'d";
  string bin_radix = "'b";
  string oct_radix = "'o";
  string unsigned_radix = "'d";
  string hex_radix = "'h";

  // Returns the prefix of the radix (for example 'h for hex), or the empty string.
  extern function string get_radix_str(uvm_radix_enum radix);

  int max_width = 999;
  string truncation = "+";
  int name_width = -1;
  int type_width = -1;
  int size_width = -1;
  int value_width = -1;
  bit sprint = 1;

endclass : uvm_printer_knobs

// uvm_printer_knobs
// -----------------

function string uvm_printer_knobs::get_radix_str(uvm_radix_enum radix);
  if (show_radix == 0) begin
    return "";
  end
  if (radix == UVM_NORADIX) begin
    radix = default_radix;
  end
  case (radix)
    UVM_BIN: begin
      return bin_radix;
    end
    UVM_OCT: begin
      return oct_radix;
    end
    UVM_DEC: begin
      return dec_radix;
    end
    UVM_HEX: begin
      return hex_radix;
    end
    UVM_UNSIGNED: begin
      return unsigned_radix;
    end
    default: begin
      return "";
    end
  endcase
endfunction : get_radix_str

`endif // IVL_UVM_PRINTER_KNOBS_SVH
`endif // IVL_UVM

// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_printer.sv
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
// Direct test of uvm_printer and uvm_table_printer (UVM 1.1d BCL classes) and
// of uvm_object::print / sprint through them. The expected tables are written
// out in full, so any change in the layout shows up. Prints PASS or FAIL per
// check and a final summary line.
module t_printer;
  import ivl_uvm_pkg::*;

  class item_t extends uvm_object;
    int a;
    string s;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "item_t";
    endfunction : get_type_name

    virtual function void do_print(
      uvm_printer printer
    );
      super.do_print(.printer(printer));
      printer.print_field(
        .name("a"),
        .value(a),
        .size(32),
        .radix(UVM_HEX)
      );
      printer.print_string(
        .name("s"),
        .value(s)
      );
    endfunction : do_print
  endclass : item_t

  class kid_t extends uvm_object;
    int kfld;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "kid_t";
    endfunction : get_type_name

    virtual function void do_print(
      uvm_printer printer
    );
      super.do_print(.printer(printer));
      printer.print_field(
        .name("kfld"),
        .value(kfld),
        .size(32),
        .radix(UVM_DEC)
      );
    endfunction : do_print
  endclass : kid_t

  class outer_t extends uvm_object;
    int ofld;
    kid_t kid;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "outer_t";
    endfunction : get_type_name

    virtual function void do_print(
      uvm_printer printer
    );
      super.do_print(.printer(printer));
      printer.print_field(
        .name("ofld"),
        .value(ofld),
        .size(8),
        .radix(UVM_BIN)
      );
      printer.print_object(
        .name("kid"),
        .value(kid)
      );
    endfunction : do_print
  endclass : outer_t

  class cyc_t extends uvm_object;
    int cycfld;
    cyc_t self;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "cyc_t";
    endfunction : get_type_name

    virtual function void do_print(
      uvm_printer printer
    );
      super.do_print(.printer(printer));
      printer.print_field(
        .name("cycfld"),
        .value(cycfld),
        .size(32),
        .radix(UVM_DEC)
      );
      printer.print_object(
        .name("self"),
        .value(self)
      );
    endfunction : do_print
  endclass : cyc_t

  class misc_t extends uvm_object;
    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "misc_t";
    endfunction : get_type_name

    virtual function void do_print(
      uvm_printer printer
    );
      super.do_print(.printer(printer));
      printer.print_array_header(
        .name("arr"),
        .size(2)
      );
      printer.print_field(
        .name(printer.index_string(.index(0), .name("arr"))),
        .value(10),
        .size(8),
        .radix(UVM_DEC)
      );
      printer.print_field(
        .name(printer.index_string(.index(1), .name("arr"))),
        .value(11),
        .size(8),
        .radix(UVM_DEC)
      );
      printer.print_array_footer();
      printer.print_real(
        .name("rl"),
        .value(1.5)
      );
      printer.print_time(
        .name("tm"),
        .value(100)
      );
      printer.print_generic(
        .name("gn"),
        .type_name("mytype"),
        .size(8),
        .value("xyz")
      );
    endfunction : do_print
  endclass : misc_t

  // user formats: header, footer and every row
  class fmt_printer extends uvm_table_printer;
    function new();
      super.new();
    endfunction : new

    virtual function string format_header();
      return "HDR";
    endfunction : format_header

    virtual function string format_footer();
      return "FTR";
    endfunction : format_footer

    virtual function string format_row(
      uvm_printer_row_info row
    );
      return {row.name, "=", row.val};
    endfunction : format_row
  endclass : fmt_printer

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("PRINTER",
                $sformatf("PASS  %-36s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("PRINTER",
                 $sformatf("FAIL  %-36s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("PRINTER",
                $sformatf("PASS  %-36s matches", what),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("PRINTER",
                 $sformatf("FAIL  %-36s\ngot:\n%s\nexpected:\n%s", what, got, exp))
    end
  endfunction : chk_str

  // number of times sub occurs in text
  function int count_of(
    string text,
    string sub
  );
    int n;
    int i;
    n = 0;
    for (i = 0; i + sub.len() <= text.len(); i++) begin
      if (text.substr(i, i + sub.len() - 1) == sub) begin
        n++;
      end
    end
    return n;
  endfunction : count_of

  function void chk_count(
    string what,
    string text,
    string sub,
    int exp
  );
    int got;
    got = count_of(
      .text(text),
      .sub(sub)
    );
    n_chk++;
    if (got == exp) begin
      `uvm_info("PRINTER",
                $sformatf("PASS  %-36s count=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("PRINTER",
                 $sformatf("FAIL  %-36s count=%0d expected=%0d in:\n%s", what, got, exp, text))
    end
  endfunction : chk_count

  uvm_table_printer tp;
  fmt_printer fp;
  uvm_printer dp;
  uvm_printer_knobs kn;
  item_t it;
  outer_t ot;
  kid_t kd;
  cyc_t cy;
  misc_t mi;
  string txt;
  string txt2;
  string dsh;

  initial begin
    $timeformat(-9, 0, " ns", 0);
    tp = new;
    fp = new;
    it = new(.name("i1"));
    it.a = 42;
    it.s = "hi";
    dsh = "---------------------------\n";

    // knob defaults
    kn = tp.knobs;
    chk_int(
      .what("knob header"),
      .got(kn.header),
      .exp(1)
    );
    chk_int(
      .what("knob indent"),
      .got(kn.indent),
      .exp(2)
    );
    chk_int(
      .what("knob depth"),
      .got(kn.depth),
      .exp(-1)
    );
    chk_int(
      .what("knob reference"),
      .got(kn.reference),
      .exp(1)
    );
    chk_str(
      .what("radix string hex"),
      .got(kn.get_radix_str(.radix(UVM_HEX))),
      .exp("'h")
    );
    chk_str(
      .what("radix string dec"),
      .got(kn.get_radix_str(.radix(UVM_DEC))),
      .exp("'d")
    );
    chk_str(
      .what("radix string bin"),
      .got(kn.get_radix_str(.radix(UVM_BIN))),
      .exp("'b")
    );
    chk_str(
      .what("radix string none uses default"),
      .got(kn.get_radix_str(.radix(UVM_NORADIX))),
      .exp("'h")
    );
    kn.show_radix = 0;
    chk_str(
      .what("radix string hidden"),
      .got(kn.get_radix_str(.radix(UVM_HEX))),
      .exp("")
    );
    kn.show_radix = 1;

    // the table
    kn.reference = 0;
    txt = it.sprint(.printer(tp));
    chk_str(
      .what("table of an item"),
      .got(txt),
      .exp({dsh,
            "Name  Type      Size  Value\n",
            dsh,
            "i1    item_t    -     -    \n",
            "  a   integral  32    'h2a \n",
            "  s   string    2     hi   \n",
            dsh})
    );
    txt2 = it.sprint(.printer(tp));
    chk_str(
      .what("second sprint is the same"),
      .got(txt2),
      .exp(txt)
    );

    // header and footer off
    kn.header = 0;
    kn.footer = 0;
    txt = it.sprint(.printer(tp));
    chk_str(
      .what("table without header and footer"),
      .got(txt),
      .exp({"i1    item_t    -     -    \n",
            "  a   integral  32    'h2a \n",
            "  s   string    2     hi   \n"})
    );
    kn.header = 1;
    kn.footer = 1;

    // columns off
    kn.type_name = 0;
    kn.size = 0;
    txt = it.sprint(.printer(tp));
    chk_count(
      .what("no type column"),
      .text(txt),
      .sub("integral"),
      .exp(0)
    );
    chk_count(
      .what("no size column"),
      .text(txt),
      .sub("Size"),
      .exp(0)
    );
    chk_count(
      .what("name column stays"),
      .text(txt),
      .sub("Name"),
      .exp(1)
    );
    kn.type_name = 1;
    kn.size = 1;

    // user formats
    kn = fp.knobs;
    kn.reference = 0;
    txt = it.sprint(.printer(fp));
    chk_str(
      .what("user header, rows and footer"),
      .got(txt),
      .exp("HDR\ni1=-\na='h2a\ns=hi\nFTR\n")
    );

    // the default printer
    dp = uvm_default_printer;
    chk_int(
      .what("default printer exists"),
      .got(dp != null),
      .exp(1)
    );
    kn = dp.knobs;
    kn.reference = 0;
    txt = it.sprint();
    chk_str(
      .what("sprint with the default printer"),
      .got(txt),
      .exp({dsh,
            "Name  Type      Size  Value\n",
            dsh,
            "i1    item_t    -     -    \n",
            "  a   integral  32    'h2a \n",
            "  s   string    2     hi   \n",
            dsh})
    );
    kn.reference = 1;
    txt = it.sprint();
    chk_count(
      .what("reference shows the instance id"),
      .text(txt),
      .sub("@"),
      .exp(1)
    );

    // print writes the table to the log
    kn = tp.knobs;
    kn.reference = 0;
    it.print(.printer(tp));

    // nested object
    kd = new(.name("k1"));
    kd.kfld = 7;
    ot = new(.name("o1"));
    ot.ofld = 5;
    ot.kid = kd;
    // print the nested table to the log
    ot.print(.printer(tp));
    txt = ot.sprint(.printer(tp));
    chk_count(
      .what("nested object row"),
      .text(txt),
      .sub("kid_t"),
      .exp(1)
    );
    chk_count(
      .what("nested object field"),
      .text(txt),
      .sub("kfld"),
      .exp(1)
    );
    chk_count(
      .what("binary radix"),
      .text(txt),
      .sub("'b101"),
      .exp(1)
    );
    chk_count(
      .what("decimal radix"),
      .text(txt),
      .sub("'d7"),
      .exp(1)
    );
    kn.depth = 1;
    txt = ot.sprint(.printer(tp));
    chk_count(
      .what("depth 1 keeps the nested row"),
      .text(txt),
      .sub("kid_t"),
      .exp(1)
    );
    chk_count(
      .what("depth 1 drops the nested field"),
      .text(txt),
      .sub("kfld"),
      .exp(0)
    );
    kn.depth = -1;
    ot.kid = null;
    txt = ot.sprint(.printer(tp));
    chk_count(
      .what("null object row"),
      .text(txt),
      .sub("object"),
      .exp(1)
    );

    // an object that contains itself prints once
    cy = new(.name("c1"));
    cy.cycfld = 3;
    cy.self = cy;
    txt = cy.sprint(.printer(tp));
    chk_count(
      .what("cycle prints the field once"),
      .text(txt),
      .sub("cycfld"),
      .exp(1)
    );
    chk_count(
      .what("cycle shows the self row"),
      .text(txt),
      .sub("self"),
      .exp(1)
    );

    // arrays, real, time and generic rows
    mi = new(.name("m1"));
    // print the array, real, time and generic rows to the log
    mi.print(.printer(tp));
    txt = mi.sprint(.printer(tp));
    chk_count(
      .what("array header row"),
      .text(txt),
      .sub("array"),
      .exp(1)
    );
    chk_count(
      .what("array element 0"),
      .text(txt),
      .sub("arr[0]"),
      .exp(1)
    );
    chk_count(
      .what("array element 1"),
      .text(txt),
      .sub("arr[1]"),
      .exp(1)
    );
    chk_count(
      .what("real value"),
      .text(txt),
      .sub("1.500000"),
      .exp(1)
    );
    chk_count(
      .what("time row"),
      .text(txt),
      .sub("time"),
      .exp(1)
    );
    chk_count(
      .what("time value printed in ns"),
      .text(txt),
      .sub("100 ns"),
      .exp(1)
    );
    chk_count(
      .what("generic type"),
      .text(txt),
      .sub("mytype"),
      .exp(1)
    );
    chk_count(
      .what("generic value"),
      .text(txt),
      .sub("xyz"),
      .exp(1)
    );

    `uvm_info("PRINTER",
              $sformatf("PRINTER: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_printer

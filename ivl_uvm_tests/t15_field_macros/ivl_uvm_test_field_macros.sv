// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_field_macros.sv
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
// Test of the field macros (uvm_object_utils_begin / uvm_field_int / string /
// enum / real / object / uvm_object_utils_end): create, copy, compare, print,
// pack, unpack and clone work on the fields that the macros list, with the
// flags UVM_NOCOPY, UVM_NOCOMPARE and a radix. Prints PASS or FAIL per check
// and a final summary line.
module t_field_macros;
  import ivl_uvm_pkg::*;

  typedef enum {RED, GREEN, BLUE} color_e;

  class kid_t extends uvm_object;
    int kv;

    `uvm_object_utils_begin(kid_t)
      `uvm_field_int(kv, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "kid_t");
      super.new(.name(name));
    endfunction : new
  endclass : kid_t

  // two fields, to see the print table
  class row_t extends uvm_object;
    int a;
    string s;

    `uvm_object_utils_begin(row_t)
      `uvm_field_int(a, UVM_ALL_ON)
      `uvm_field_string(s, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "row_t");
      super.new(.name(name));
    endfunction : new
  endclass : row_t

  class pkt_t extends uvm_object;
    int a;
    bit [7:0] b;
    string s;
    color_e c;
    real r;
    kid_t kid;
    int nocopy;
    int nocmp;

    `uvm_object_utils_begin(pkt_t)
      `uvm_field_int(a, UVM_ALL_ON)
      `uvm_field_int(b, UVM_ALL_ON | UVM_DEC)
      `uvm_field_string(s, UVM_ALL_ON)
      `uvm_field_enum(color_e, c, UVM_ALL_ON)
      `uvm_field_real(r, UVM_ALL_ON)
      `uvm_field_object(kid, UVM_ALL_ON)
      `uvm_field_int(nocopy, UVM_ALL_ON | UVM_NOCOPY)
      `uvm_field_int(nocmp, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "pkt_t");
      super.new(.name(name));
    endfunction : new
  endclass : pkt_t

  // a derived class: the fields of the base class are handled too
  class sub_t extends pkt_t;
    int w;

    `uvm_object_utils_begin(sub_t)
      `uvm_field_int(w, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "sub_t");
      super.new(.name(name));
    endfunction : new
  endclass : sub_t

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("FIELD_MACROS",
                $sformatf("PASS  %-36s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("FIELD_MACROS",
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
      `uvm_info("FIELD_MACROS",
                $sformatf("PASS  %-36s matches", what),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("FIELD_MACROS",
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
      `uvm_info("FIELD_MACROS",
                $sformatf("PASS  %-36s count=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("FIELD_MACROS",
                 $sformatf("FAIL  %-36s count=%0d expected=%0d in:\n%s", what, got, exp, text))
    end
  endfunction : chk_count

  uvm_table_printer tp;
  uvm_packer pk;
  uvm_packer pku;
  uvm_printer_knobs kn;
  row_t rw;
  pkt_t p1, p2, p3, cp;
  sub_t s1, s2;
  kid_t k1;
  kid_t ka;
  uvm_object o;
  uvm_object made;
  bit bits[];
  int nbits;
  string txt;
  string dsh;

  initial begin
    tp = new;
    pk = new;
    pku = new;
    pk.use_metadata = 1;
    pku.use_metadata = 1;
    kn = tp.knobs;
    kn.reference = 0;
    dsh = "---------------------------\n";

    // the print table of the listed fields
    rw = new(.name("r1"));
    rw.a = 42;
    rw.s = "hi";
    txt = rw.sprint(.printer(tp));
    chk_str(
      .what("print table of two fields"),
      .got(txt),
      .exp({dsh,
            "Name  Type      Size  Value\n",
            dsh,
            "r1    row_t     -     -    \n",
            "  a   integral  32    'h2a \n",
            "  s   string    2     hi   \n",
            dsh})
    );

    // create and the type name come from the macro
    p1 = new(.name("p1"));
    made = p1.create(.name("made"));
    chk_int(
      .what("create returns an object"),
      .got(made != null),
      .exp(1)
    );
    chk_str(
      .what("create sets the name"),
      .got(made.get_name()),
      .exp("made")
    );
    chk_str(
      .what("type name from the macro"),
      .got(p1.get_type_name()),
      .exp("pkt_t")
    );

    // copy
    k1 = new(.name("k1"));
    k1.kv = 77;
    p1.a = 5;
    p1.b = 100;
    p1.s = "abc";
    p1.c = BLUE;
    p1.r = 2.5;
    p1.kid = k1;
    p1.nocopy = 11;
    p1.nocmp = 12;
    p2 = new(.name("p2"));
    p2.nocopy = 99;
    p2.copy(.rhs(p1));
    chk_int(
      .what("copy int"),
      .got(p2.a),
      .exp(5)
    );
    chk_int(
      .what("copy bit vector"),
      .got(p2.b),
      .exp(100)
    );
    chk_str(
      .what("copy string"),
      .got(p2.s),
      .exp("abc")
    );
    chk_int(
      .what("copy enum"),
      .got(p2.c),
      .exp(BLUE)
    );
    chk_int(
      .what("copy real"),
      .got(p2.r == 2.5),
      .exp(1)
    );
    ka = p2.kid;
    chk_int(
      .what("copy object is a new object"),
      .got(ka != null && ka != k1),
      .exp(1)
    );
    if (ka != null) begin
      chk_int(
        .what("copy object field"),
        .got(ka.kv),
        .exp(77)
      );
    end
    chk_int(
      .what("UVM_NOCOPY is not copied"),
      .got(p2.nocopy),
      .exp(99)
    );
    chk_int(
      .what("UVM_NOCOMPARE is copied"),
      .got(p2.nocmp),
      .exp(12)
    );
    chk_str(
      .what("copy keeps the name"),
      .got(p2.get_name()),
      .exp("p2")
    );

    // compare
    p2.nocopy = p1.nocopy;
    chk_int(
      .what("compare equal"),
      .got(p1.compare(.rhs(p2))),
      .exp(1)
    );
    p2.a = 6;
    chk_int(
      .what("compare differs in an int"),
      .got(p1.compare(.rhs(p2))),
      .exp(0)
    );
    p2.a = 5;
    p2.s = "abd";
    chk_int(
      .what("compare differs in a string"),
      .got(p1.compare(.rhs(p2))),
      .exp(0)
    );
    p2.s = "abc";
    p2.c = RED;
    chk_int(
      .what("compare differs in an enum"),
      .got(p1.compare(.rhs(p2))),
      .exp(0)
    );
    p2.c = BLUE;
    p2.r = 2.75;
    chk_int(
      .what("compare differs in a real"),
      .got(p1.compare(.rhs(p2))),
      .exp(0)
    );
    p2.r = 2.5;
    ka = p2.kid;
    ka.kv = 78;
    chk_int(
      .what("compare differs in an object field"),
      .got(p1.compare(.rhs(p2))),
      .exp(0)
    );
    ka.kv = 77;
    p2.nocmp = 13;
    chk_int(
      .what("UVM_NOCOMPARE is ignored"),
      .got(p1.compare(.rhs(p2))),
      .exp(1)
    );

    // print: every listed field is a row, with the radix of the flag
    p1.nocopy = 11;
    txt = p1.sprint(.printer(tp));
    chk_count(
      .what("print row for the int"),
      .text(txt),
      .sub("'h5"),
      .exp(1)
    );
    chk_count(
      .what("print decimal radix of the flag"),
      .text(txt),
      .sub("'d100"),
      .exp(1)
    );
    chk_count(
      .what("print string row"),
      .text(txt),
      .sub("abc"),
      .exp(1)
    );
    chk_count(
      .what("print enum row"),
      .text(txt),
      .sub("BLUE"),
      .exp(1)
    );
    chk_count(
      .what("print real row"),
      .text(txt),
      .sub("2.500000"),
      .exp(1)
    );
    chk_count(
      .what("print object row"),
      .text(txt),
      .sub("kid_t"),
      .exp(1)
    );
    chk_count(
      .what("print object field"),
      .text(txt),
      .sub("kv"),
      .exp(1)
    );
    p1.print(.printer(tp));

    // pack and unpack
    // with metadata: a null byte after the string, 4 bits before the object
    nbits = p1.pack(bits, pk);
    chk_int(
      .what("pack size in bits"),
      .got(nbits),
      .exp(268)
    );
    p3 = new(.name("p3"));
    p3.kid = new(.name("k3"));
    void'(p3.unpack(bits, pku));
    chk_int(
      .what("unpack int"),
      .got(p3.a),
      .exp(5)
    );
    chk_int(
      .what("unpack bit vector"),
      .got(p3.b),
      .exp(100)
    );
    chk_str(
      .what("unpack string"),
      .got(p3.s),
      .exp("abc")
    );
    chk_int(
      .what("unpack enum"),
      .got(p3.c),
      .exp(BLUE)
    );
    chk_int(
      .what("unpack real"),
      .got(p3.r == 2.5),
      .exp(1)
    );
    ka = p3.kid;
    chk_int(
      .what("unpack object field"),
      .got(ka.kv),
      .exp(77)
    );
    chk_int(
      .what("unpack gives an equal object"),
      .got(p1.compare(.rhs(p3))),
      .exp(1)
    );

    // clone
    o = p1.clone();
    chk_int(
      .what("clone casts to pkt_t"),
      .got($cast(cp, o)),
      .exp(1)
    );
    chk_int(
      .what("clone is a new object"),
      .got(cp != p1),
      .exp(1)
    );
    chk_int(
      .what("clone leaves UVM_NOCOPY at default"),
      .got(cp.nocopy),
      .exp(0)
    );
    cp.nocopy = p1.nocopy;
    chk_int(
      .what("clone is equal"),
      .got(p1.compare(.rhs(cp))),
      .exp(1)
    );
    ka = cp.kid;
    chk_int(
      .what("clone object field is deep"),
      .got(ka != k1),
      .exp(1)
    );

    // a null object handle
    p2.kid = null;
    p3.copy(.rhs(p2));
    chk_int(
      .what("copy of a null object handle"),
      .got(p3.kid == null),
      .exp(1)
    );

    // derived class: the fields of both classes
    s1 = new(.name("s1"));
    s1.a = 1;
    s1.s = "zzz";
    s1.w = 9;
    s1.kid = k1;
    s2 = new(.name("s2"));
    s2.copy(.rhs(s1));
    chk_int(
      .what("derived copy base field"),
      .got(s2.a),
      .exp(1)
    );
    chk_int(
      .what("derived copy own field"),
      .got(s2.w),
      .exp(9)
    );
    chk_int(
      .what("derived compare equal"),
      .got(s1.compare(.rhs(s2))),
      .exp(1)
    );
    s2.w = 10;
    chk_int(
      .what("derived compare differs in own field"),
      .got(s1.compare(.rhs(s2))),
      .exp(0)
    );
    txt = s1.sprint(.printer(tp));
    chk_count(
      .what("derived print has the own field"),
      .text(txt),
      .sub("  w "),
      .exp(1)
    );
    chk_count(
      .what("derived print has the base field"),
      .text(txt),
      .sub("zzz"),
      .exp(1)
    );

    `uvm_info("FIELD_MACROS",
              $sformatf("FIELD_MACROS: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_field_macros

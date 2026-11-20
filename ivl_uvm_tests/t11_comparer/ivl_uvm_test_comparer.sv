// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_comparer.sv
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
// Direct test of uvm_comparer (UVM 1.1d BCL class) and of uvm_object::compare.
// Part 1 calls the compare_* methods directly, part 2 compares objects through
// do_compare. Prints PASS or FAIL per check and a final summary line.
module t_comparer;
  import ivl_uvm_pkg::*;

  class pkt_t extends uvm_object;
    int a;
    string s;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "pkt_t";
    endfunction : get_type_name

    virtual function bit do_compare(
      uvm_object rhs,
      uvm_comparer comparer
    );
      pkt_t r;
      bit ok;
      ok = super.do_compare(
        .rhs(rhs),
        .comparer(comparer)
      );
      // $cast of a null rhs succeeds and leaves r null
      if (!$cast(r, rhs) || r == null) begin
        return 0;
      end
      ok &= comparer.compare_field_int(
        .name("a"),
        .lhs(a),
        .rhs(r.a),
        .size(32)
      );
      ok &= comparer.compare_string(
        .name("s"),
        .lhs(s),
        .rhs(r.s)
      );
      return ok;
    endfunction : do_compare
  endclass : pkt_t

  class node_t extends uvm_object;
    int v;
    node_t next;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "node_t";
    endfunction : get_type_name

    virtual function bit do_compare(
      uvm_object rhs,
      uvm_comparer comparer
    );
      node_t r;
      bit ok;
      ok = super.do_compare(
        .rhs(rhs),
        .comparer(comparer)
      );
      // $cast of a null rhs succeeds and leaves r null
      if (!$cast(r, rhs) || r == null) begin
        return 0;
      end
      ok &= comparer.compare_field_int(
        .name("v"),
        .lhs(v),
        .rhs(r.v),
        .size(32)
      );
      ok &= comparer.compare_object(
        .name("next"),
        .lhs(next),
        .rhs(r.next)
      );
      return ok;
    endfunction : do_compare
  endclass : node_t

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("COMPARER",
                $sformatf("PASS  %-34s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COMPARER",
                 $sformatf("FAIL  %-34s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  // the compared text can hold new lines, so a pass does not print it
  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("COMPARER",
                $sformatf("PASS  %-34s", what),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COMPARER",
                 $sformatf("FAIL  %-34s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  uvm_comparer c;
  uvm_comparer c2;
  uvm_status_container sc;
  uvm_scope_stack s;
  pkt_t p1, p2, p3;
  node_t n1, n2, n3, n4;
  uvm_bitstream_t w1, w2;
  bit ok;

  // A new comparer that keeps the first miscompare quiet when smax is 0, and a
  // scope of "top" so that a field name f is reported as top.f
  function void fresh(
    int smax
  );
    c = new;
    c.show_max = smax;
    s.set(.s("top"));
  endfunction : fresh

  // Scope depth 0, as uvm_object::compare expects at the top of a comparison
  function void at_top();
    s.set(.s("top"));
    s.up();
  endfunction : at_top

  initial begin
    p1 = new(.name("pkt"));
    p2 = new(.name("pkt"));
    p3 = new(.name("pkt"));
    n1 = new(.name("a"));
    n2 = new(.name("b"));
    n3 = new(.name("c"));
    n4 = new(.name("d"));
    sc = uvm_object::__m_uvm_status_container;
    s = sc.scope;

    // defaults
    c = new;
    chk_int(
      .what("default show_max"),
      .got(c.show_max),
      .exp(1)
    );
    chk_int(
      .what("default verbosity"),
      .got(c.verbosity),
      .exp(UVM_LOW)
    );
    chk_int(
      .what("default sev"),
      .got(c.sev),
      .exp(UVM_INFO)
    );
    chk_int(
      .what("default check_type"),
      .got(c.check_type),
      .exp(1)
    );
    chk_int(
      .what("default result"),
      .got(c.result),
      .exp(0)
    );
    chk_str(
      .what("default miscompares"),
      .got(c.miscompares),
      .exp("")
    );
    c2 = uvm_comparer::init();
    chk_int(
      .what("init returns default comparer"),
      .got(c2 == uvm_default_comparer),
      .exp(1)
    );

    // compare_field_int
    fresh(.smax(0));
    ok = c.compare_field_int(
      .name("f"),
      .lhs(5),
      .rhs(5),
      .size(8)
    );
    chk_int(
      .what("field_int equal"),
      .got(ok),
      .exp(1)
    );
    chk_int(
      .what("field_int equal result"),
      .got(c.result),
      .exp(0)
    );
    ok = c.compare_field_int(
      .name("f"),
      .lhs(5),
      .rhs(6),
      .size(8)
    );
    chk_int(
      .what("field_int differ"),
      .got(ok),
      .exp(0)
    );
    chk_int(
      .what("field_int differ result"),
      .got(c.result),
      .exp(1)
    );
    chk_str(
      .what("field_int hex text"),
      .got(c.miscompares),
      .exp("top.f: lhs = 'h5 : rhs = 'h6\n")
    );
    fresh(.smax(0));
    ok = c.compare_field_int(
      .name("f"),
      .lhs('h1F),
      .rhs('h0F),
      .size(4)
    );
    chk_int(
      .what("field_int size mask equal"),
      .got(ok),
      .exp(1)
    );
    ok = c.compare_field_int(
      .name("f"),
      .lhs('h1F),
      .rhs('h0F),
      .size(8)
    );
    chk_int(
      .what("field_int size mask differ"),
      .got(ok),
      .exp(0)
    );

    // radix in the miscompare text
    fresh(.smax(0));
    ok = c.compare_field_int(
      .name("f"),
      .lhs(5),
      .rhs(6),
      .size(8),
      .radix(UVM_BIN)
    );
    chk_str(
      .what("field_int bin text"),
      .got(c.miscompares),
      .exp("top.f: lhs = 'b101 : rhs = 'b110\n")
    );
    fresh(.smax(0));
    ok = c.compare_field_int(
      .name("f"),
      .lhs(8),
      .rhs(9),
      .size(8),
      .radix(UVM_OCT)
    );
    chk_str(
      .what("field_int oct text"),
      .got(c.miscompares),
      .exp("top.f: lhs = 'o10 : rhs = 'o11\n")
    );
    fresh(.smax(0));
    ok = c.compare_field_int(
      .name("f"),
      .lhs(5),
      .rhs(6),
      .size(8),
      .radix(UVM_DEC)
    );
    chk_str(
      .what("field_int dec text"),
      .got(c.miscompares),
      .exp("top.f: lhs = 5 : rhs = 6\n")
    );
    fresh(.smax(0));
    ok = c.compare_field_int(
      .name("f"),
      .lhs(5),
      .rhs(6),
      .size(8),
      .radix(UVM_ENUM)
    );
    chk_str(
      .what("field_int enum text"),
      .got(c.miscompares),
      .exp("top.f: lhs = 5 : rhs = 6\n")
    );

    // compare_field above 64 bits
    fresh(.smax(0));
    w1 = 0;
    w2 = 0;
    w1[80] = 1;
    ok = c.compare_field(
      .name("w"),
      .lhs(w1),
      .rhs(w2),
      .size(100)
    );
    chk_int(
      .what("field 100 bits differ"),
      .got(ok),
      .exp(0)
    );
    chk_int(
      .what("field 100 bits result"),
      .got(c.result),
      .exp(1)
    );
    fresh(.smax(0));
    w1 = 0;
    w2 = 0;
    w1[120] = 1;
    ok = c.compare_field(
      .name("w"),
      .lhs(w1),
      .rhs(w2),
      .size(100)
    );
    chk_int(
      .what("field 100 bits above size"),
      .got(ok),
      .exp(1)
    );
    fresh(.smax(0));
    ok = c.compare_field(
      .name("w"),
      .lhs(3),
      .rhs(4),
      .size(32)
    );
    chk_int(
      .what("field 32 bits uses field_int"),
      .got(ok),
      .exp(0)
    );

    // compare_field_real and compare_string
    fresh(.smax(0));
    ok = c.compare_field_real(
      .name("r"),
      .lhs(1.5),
      .rhs(1.5)
    );
    chk_int(
      .what("field_real equal"),
      .got(ok),
      .exp(1)
    );
    ok = c.compare_field_real(
      .name("r"),
      .lhs(1.5),
      .rhs(2.5)
    );
    chk_int(
      .what("field_real differ"),
      .got(ok),
      .exp(0)
    );
    chk_int(
      .what("field_real result"),
      .got(c.result),
      .exp(1)
    );
    fresh(.smax(0));
    ok = c.compare_string(
      .name("s"),
      .lhs("abc"),
      .rhs("abc")
    );
    chk_int(
      .what("string equal"),
      .got(ok),
      .exp(1)
    );
    ok = c.compare_string(
      .name("s"),
      .lhs("abc"),
      .rhs("abd")
    );
    chk_int(
      .what("string differ"),
      .got(ok),
      .exp(0)
    );
    chk_str(
      .what("string text"),
      .got(c.miscompares),
      .exp("top.s: lhs = \"abc\" : rhs = \"abd\"\n")
    );

    // show_max: all miscompares are counted, only show_max are reported
    fresh(.smax(1));
    ok = c.compare_field_int(
      .name("f"),
      .lhs(1),
      .rhs(2),
      .size(8)
    );
    ok = c.compare_field_int(
      .name("g"),
      .lhs(3),
      .rhs(4),
      .size(8)
    );
    chk_int(
      .what("show_max 1 counts both"),
      .got(c.result),
      .exp(2)
    );

    // compare_object without a deep compare
    fresh(.smax(0));
    ok = c.compare_object(
      .name("o"),
      .lhs(p1),
      .rhs(p1)
    );
    chk_int(
      .what("object same handle"),
      .got(ok),
      .exp(1)
    );
    ok = c.compare_object(
      .name("o"),
      .lhs(p1),
      .rhs(null)
    );
    chk_int(
      .what("object vs null"),
      .got(ok),
      .exp(0)
    );
    chk_int(
      .what("object vs null result"),
      .got(c.result),
      .exp(1)
    );
    fresh(.smax(0));
    c.policy = UVM_REFERENCE;
    ok = c.compare_object(
      .name("o"),
      .lhs(p1),
      .rhs(p2)
    );
    chk_int(
      .what("object reference policy"),
      .got(ok),
      .exp(0)
    );
    chk_int(
      .what("object reference result"),
      .got(c.result),
      .exp(1)
    );

    // uvm_object::compare through do_compare
    p1.a = 1;
    p1.s = "x";
    p2.a = 1;
    p2.s = "x";
    p3.a = 2;
    p3.s = "y";
    at_top();
    c = new;
    c.show_max = 0;
    ok = p1.compare(
      .rhs(p2),
      .comparer(c)
    );
    chk_int(
      .what("compare equal"),
      .got(ok),
      .exp(1)
    );
    chk_int(
      .what("compare equal result"),
      .got(c.result),
      .exp(0)
    );
    ok = p1.compare(
      .rhs(p1),
      .comparer(c)
    );
    chk_int(
      .what("compare self"),
      .got(ok),
      .exp(1)
    );
    p2.a = 2;
    ok = p1.compare(
      .rhs(p2),
      .comparer(c)
    );
    chk_int(
      .what("compare a differs"),
      .got(ok),
      .exp(0)
    );
    chk_int(
      .what("compare a differs result"),
      .got(c.result),
      .exp(1)
    );
    chk_str(
      .what("compare a differs text"),
      .got(c.miscompares),
      .exp("pkt.a: lhs = 'h1 : rhs = 'h2\n")
    );
    ok = p1.compare(
      .rhs(p3),
      .comparer(c)
    );
    chk_int(
      .what("compare a and s differ result"),
      .got(c.result),
      .exp(2)
    );
    chk_str(
      .what("compare a and s differ text"),
      .got(c.miscompares),
      .exp("pkt.a: lhs = 'h1 : rhs = 'h2\npkt.s: lhs = \"x\" : rhs = \"y\"\n")
    );
    ok = p1.compare(
      .rhs(null),
      .comparer(c)
    );
    chk_int(
      .what("compare vs null"),
      .got(ok),
      .exp(0)
    );
    chk_int(
      .what("compare vs null result"),
      .got(c.result),
      .exp(1)
    );
    ok = p1.compare(
      .rhs(n1),
      .comparer(c)
    );
    chk_int(
      .what("compare other type"),
      .got(ok),
      .exp(0)
    );
    chk_int(
      .what("compare other type result"),
      .got(c.result),
      .exp(1)
    );
    chk_str(
      .what("compare other type text"),
      .got(c.miscompares),
      .exp("pkt: lhs type = \"pkt_t\" : rhs type = \"node_t\"\n")
    );

    // a rollup message when the severity is not INFO
    c.sev = UVM_WARNING;
    ok = p1.compare(
      .rhs(p3),
      .comparer(c)
    );
    chk_int(
      .what("compare warning rollup result"),
      .got(c.result),
      .exp(2)
    );

    // objects that point to each other: the comparison must end
    n1.v = 1;
    n2.v = 2;
    n1.next = n2;
    n2.next = n1;
    n3.v = 1;
    n4.v = 2;
    n3.next = n4;
    n4.next = n3;
    c = new;
    c.show_max = 0;
    ok = n1.compare(
      .rhs(n3),
      .comparer(c)
    );
    chk_int(
      .what("cyclic equal result"),
      .got(c.result),
      .exp(0)
    );
    n4.v = 9;
    c = new;
    c.show_max = 0;
    ok = n1.compare(
      .rhs(n3),
      .comparer(c)
    );
    chk_int(
      .what("cyclic differ result"),
      .got(c.result),
      .exp(1)
    );
    chk_str(
      .what("cyclic differ text"),
      .got(c.miscompares),
      .exp("a.next.v: lhs = 'h2 : rhs = 'h9\n")
    );

    `uvm_info("COMPARER",
              $sformatf("COMPARER: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_comparer

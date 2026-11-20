// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_registry.sv
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
// Direct test of the type_id registry (uvm_object_registry, uvm_object_wrapper)
// that the uvm_object_utils macros add to a class: type_id::create with and
// without a name, a subclass with its own registry, get_type and
// get_object_type (one registry object per class), create_object on the
// registry, a parameterized class (no lookup name, one registry per
// specialization), and the factory entry points by name and by type. Prints
// PASS or FAIL per check and a final summary line.
module t_registry;
  import ivl_uvm_pkg::*;

  class item_a extends uvm_object;
    int v;

    `uvm_object_utils(item_a)

    function new(string name = "item_a");
      super.new(name);
    endfunction : new
  endclass : item_a

  class item_b extends item_a;
    `uvm_object_utils(item_b)

    function new(string name = "item_b");
      super.new(name);
    endfunction : new
  endclass : item_b

  class sitem_t extends uvm_sequence_item;
    `uvm_object_utils(sitem_t)

    function new(string name = "sitem_t");
      super.new(name);
    endfunction : new
  endclass : sitem_t

  class pt #(int W = 8) extends uvm_object;
    bit [W-1:0] d;

    `uvm_object_param_utils(pt #(W))

    function new(string name = "pt");
      super.new(name);
    endfunction : new
  endclass : pt

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("REGISTRY",
                $sformatf("PASS  %-40s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("REGISTRY",
                 $sformatf("FAIL  %-40s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("REGISTRY",
                $sformatf("PASS  %-40s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("REGISTRY",
                 $sformatf("FAIL  %-40s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  item_a a, a2, a3, a4, ca;
  item_b b, cb;
  sitem_t s;
  uvm_object_wrapper w, w2, wb;
  uvm_object o;
  pt #(8) p8;
  pt #(16) p16;
  uvm_object_wrapper w8, w16;

  initial begin
    // create through type_id
    a = item_a::type_id::create(.name("x"));
    chk_int(
      .what("create returns an object"),
      .got(a != null),
      .exp(1)
    );
    chk_str(
      .what("create sets the name"),
      .got(a.get_name()),
      .exp("x")
    );
    chk_str(
      .what("created type name"),
      .got(a.get_type_name()),
      .exp("item_a")
    );
    a2 = item_a::type_id::create();
    chk_str(
      .what("no name keeps the constructor default"),
      .got(a2.get_name()),
      .exp("item_a")
    );
    a4 = item_a::type_id::create(
      .name("pp"),
      .parent(null),
      .contxt("top.env")
    );
    chk_str(
      .what("create with parent and context"),
      .got(a4.get_name()),
      .exp("pp")
    );

    // a subclass has its own registry
    b = item_b::type_id::create(.name("y"));
    chk_str(
      .what("subclass created type name"),
      .got(b.get_type_name()),
      .exp("item_b")
    );
    chk_str(
      .what("subclass name"),
      .got(b.get_name()),
      .exp("y")
    );
    chk_int(
      .what("subclass handle fits the base type"),
      .got($cast(a3, b)),
      .exp(1)
    );

    // a class derived from uvm_sequence_item
    s = sitem_t::type_id::create(.name("s"));
    chk_str(
      .what("sequence item type name"),
      .got(s.get_type_name()),
      .exp("sitem_t")
    );
    chk_int(
      .what("sequence item keeps its defaults"),
      .got(s.get_sequence_id()),
      .exp(-1)
    );

    // get_type and get_object_type: one registry object per class
    w = item_a::get_type();
    wb = item_b::get_type();
    chk_str(
      .what("registry type name"),
      .got(w.get_type_name()),
      .exp("item_a")
    );
    chk_str(
      .what("subclass registry type name"),
      .got(wb.get_type_name()),
      .exp("item_b")
    );
    chk_int(
      .what("registries differ"),
      .got(w != wb),
      .exp(1)
    );
    w2 = item_a::get_type();
    chk_int(
      .what("get_type returns the same registry"),
      .got(w2 == w),
      .exp(1)
    );
    w2 = a.get_object_type();
    chk_int(
      .what("get_object_type is the class registry"),
      .got(w2 == w),
      .exp(1)
    );
    a3 = b;
    w2 = a3.get_object_type();
    chk_int(
      .what("get_object_type is virtual"),
      .got(w2 == wb),
      .exp(1)
    );

    // create_object on the registry
    o = w.create_object(.name("z"));
    chk_int(
      .what("create_object returns the class"),
      .got($cast(ca, o)),
      .exp(1)
    );
    chk_str(
      .what("create_object sets the name"),
      .got(ca.get_name()),
      .exp("z")
    );
    o = wb.create_object();
    chk_int(
      .what("subclass create_object returns the subclass"),
      .got($cast(cb, o)),
      .exp(1)
    );

    // a parameterized class: no lookup name, one registry per specialization
    p8 = pt #(8)::type_id::create(.name("p8"));
    p16 = pt #(16)::type_id::create(.name("p16"));
    chk_str(
      .what("parameterized create sets the name"),
      .got(p8.get_name()),
      .exp("p8")
    );
    chk_int(
      .what("parameterized width kept"),
      .got($bits(p16.d)),
      .exp(16)
    );
    w8 = pt #(8)::get_type();
    w16 = pt #(16)::get_type();
    chk_str(
      .what("parameterized registry has no name"),
      .got(w8.get_type_name()),
      .exp("<unknown>")
    );
    chk_int(
      .what("one registry per specialization"),
      .got(w8 != w16),
      .exp(1)
    );
    w2 = p8.get_object_type();
    chk_int(
      .what("parameterized get_object_type"),
      .got(w2 == w8),
      .exp(1)
    );

    // the factory by name and by type
    chk_int(
      .what("factory knows the type name"),
      .got(factory.is_type_name_registered(.type_name("item_a"))),
      .exp(1)
    );
    o = factory.create_object_by_name(
      .requested_type_name("item_b"),
      .parent_inst_path(""),
      .name("n")
    );
    chk_str(
      .what("create_object_by_name type"),
      .got(o.get_type_name()),
      .exp("item_b")
    );
    chk_str(
      .what("create_object_by_name name"),
      .got(o.get_name()),
      .exp("n")
    );
    o = factory.create_object_by_type(
      .requested_type(w),
      .parent_inst_path(""),
      .name("q")
    );
    chk_str(
      .what("create_object_by_type type"),
      .got(o.get_type_name()),
      .exp("item_a")
    );
    chk_str(
      .what("create_object_by_type name"),
      .got(o.get_name()),
      .exp("q")
    );

    `uvm_info("REGISTRY",
              $sformatf("REGISTRY: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_registry

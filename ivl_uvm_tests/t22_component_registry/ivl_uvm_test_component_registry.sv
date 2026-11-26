// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_component_registry.sv
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
// Direct test of the component registry: my_comp::type_id::create(name,
// parent) for a component with uvm_component_utils, a subclass with its own
// type_id, get_type(), get_object_type(), creation by type name through the
// factory, and the parent / full name set by create. Prints PASS or FAIL per
// check and a final summary line.
package comp_registry_pkg;
  import ivl_uvm_pkg::*;

  class base_comp extends uvm_component;
    `uvm_component_utils(base_comp)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new
  endclass : base_comp

  class derived_comp extends base_comp;
    `uvm_component_utils(derived_comp)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new
  endclass : derived_comp
endpackage : comp_registry_pkg

module t_comp_registry;
  import ivl_uvm_pkg::*;
  import comp_registry_pkg::*;

  int n_fail;
  int n_chk;

  function void chk_s(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("COMP_REGISTRY",
                $sformatf("PASS  %-30s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COMP_REGISTRY",
                 $sformatf("FAIL  %-30s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_s

  function void chk_i(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("COMP_REGISTRY",
                $sformatf("PASS  %-30s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COMP_REGISTRY",
                 $sformatf("FAIL  %-30s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_i

  base_comp top;
  base_comp c1;
  base_comp c2;
  derived_comp d1;
  derived_comp d_cast;
  uvm_component by_name;
  uvm_object_wrapper w;
  uvm_object_wrapper w2;
  string nm;

  initial begin
    // a top-level component made with type_id::create
    top = base_comp::type_id::create(
      .name("top"),
      .parent(null)
    );
    chk_i(
      .what("create returns a handle"),
      .got(top != null),
      .exp(1)
    );
    nm = top.get_name();
    chk_s(
      .what("top name"),
      .got(nm),
      .exp("top")
    );
    nm = top.get_type_name();
    chk_s(
      .what("top type name"),
      .got(nm),
      .exp("base_comp")
    );

    // children made with a parent
    c1 = base_comp::type_id::create(
      .name("c1"),
      .parent(top)
    );
    c2 = base_comp::type_id::create(
      .name("c2"),
      .parent(top)
    );
    nm = c1.get_full_name();
    chk_s(
      .what("child full name"),
      .got(nm),
      .exp("top.c1")
    );
    chk_i(
      .what("child parent is top"),
      .got(c1.get_parent() == top),
      .exp(1)
    );
    chk_i(
      .what("top children"),
      .got(top.get_num_children()),
      .exp(2)
    );

    // a subclass with its own type_id
    d1 = derived_comp::type_id::create(
      .name("d1"),
      .parent(top)
    );
    nm = d1.get_type_name();
    chk_s(
      .what("derived type name"),
      .got(nm),
      .exp("derived_comp")
    );
    nm = d1.get_full_name();
    chk_s(
      .what("derived full name"),
      .got(nm),
      .exp("top.d1")
    );

    // get_type() and get_object_type()
    w = base_comp::get_type();
    nm = w.get_type_name();
    chk_s(
      .what("get_type name"),
      .got(nm),
      .exp("base_comp")
    );
    w2 = d1.get_object_type();
    nm = w2.get_type_name();
    chk_s(
      .what("get_object_type name"),
      .got(nm),
      .exp("derived_comp")
    );

    // by type name through the factory
    by_name = factory.create_component_by_name(
      .requested_type_name("derived_comp"),
      .name("by_name"),
      .parent(top)
    );
    chk_i(
      .what("by name returns a handle"),
      .got(by_name != null),
      .exp(1)
    );
    chk_i(
      .what("by name is a derived_comp"),
      .got($cast(d_cast, by_name)),
      .exp(1)
    );

    `uvm_info("COMP_REGISTRY",
              $sformatf("COMP_REGISTRY: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_comp_registry

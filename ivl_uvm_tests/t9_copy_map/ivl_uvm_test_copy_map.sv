// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_copy_map.sv
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
// Direct test of uvm_copy_map (UVM 1.1d API: set, get, delete, clear).
// The BCL class keys an associative array by object handle; on Icarus it is
// a linked list (ivl_uvm_linked_list). Prints PASS or FAIL per check and a
// final summary line.
module t_copy_map;
  import ivl_uvm_pkg::*;

  class obj_a extends uvm_object;
    function new(string name = "");
      super.new(.name(name));
    endfunction : new
  endclass : obj_a

  class obj_b extends obj_a;
    int tag;
    function new(string name = "");
      super.new(.name(name));
      tag = 7;
    endfunction : new
  endclass : obj_b

  int n_fail;
  int n_chk;

  function string nm(uvm_object o);
    if (o == null) begin
      return "null";
    end
    return o.get_name();
  endfunction : nm

  function void chk(
    string what,
    uvm_object got,
    uvm_object exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("COPY_MAP",
                $sformatf("PASS  %-26s got=%s", what, nm(.o(got))),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COPY_MAP",
                 $sformatf("FAIL  %-26s got=%s expected=%s", what, nm(.o(got)), nm(.o(exp))))
    end
  endfunction : chk

  uvm_copy_map m;
  uvm_copy_map m2;
  obj_a k1, k2, k3, v1, v2, v3;
  obj_a ks[20];
  obj_a vs[20];
  obj_b db;
  obj_b dgot;
  uvm_object r;

  initial begin
    m  = new;
    m2 = new;
    k1 = new(.name("k1"));
    k2 = new(.name("k2"));
    k3 = new(.name("k3"));
    v1 = new(.name("v1"));
    v2 = new(.name("v2"));
    v3 = new(.name("v3"));

    chk(
      .what("empty map, get"),
      .got(m.get(.key(k1))),
      .exp(null)
    );

    m.set(
      .key(k1),
      .obj(v1)
    );
    chk(
      .what("set/get k1"),
      .got(m.get(.key(k1))),
      .exp(v1)
    );
    chk(
      .what("other key missing"),
      .got(m.get(.key(k2))),
      .exp(null)
    );

    m.set(
      .key(k2),
      .obj(v2)
    );
    m.set(
      .key(k3),
      .obj(v3)
    );
    chk(
      .what("get k1 of 3"),
      .got(m.get(.key(k1))),
      .exp(v1)
    );
    chk(
      .what("get k2 of 3"),
      .got(m.get(.key(k2))),
      .exp(v2)
    );
    chk(
      .what("get k3 of 3"),
      .got(m.get(.key(k3))),
      .exp(v3)
    );

    // overwrite must replace, not add a second entry
    m.set(
      .key(k2),
      .obj(v1)
    );
    chk(
      .what("overwrite k2"),
      .got(m.get(.key(k2))),
      .exp(v1)
    );
    m.delete(.v(k2));
    chk(
      .what("k2 gone after delete"),
      .got(m.get(.key(k2))),
      .exp(null)
    );
    chk(
      .what("k1 kept"),
      .got(m.get(.key(k1))),
      .exp(v1)
    );
    chk(
      .what("k3 kept"),
      .got(m.get(.key(k3))),
      .exp(v3)
    );

    // delete at head, tail, then a missing key (no effect)
    m.set(
      .key(k2),
      .obj(v2)
    );
    m.delete(.v(k1));
    chk(
      .what("delete first-added"),
      .got(m.get(.key(k1))),
      .exp(null)
    );
    chk(
      .what("k2 after delete"),
      .got(m.get(.key(k2))),
      .exp(v2)
    );
    chk(
      .what("k3 after delete"),
      .got(m.get(.key(k3))),
      .exp(v3)
    );
    m.delete(.v(k3));
    chk(
      .what("delete last-added"),
      .got(m.get(.key(k3))),
      .exp(null)
    );
    chk(
      .what("k2 after 2 deletes"),
      .got(m.get(.key(k2))),
      .exp(v2)
    );
    m.delete(.v(k1));
    chk(
      .what("delete missing key"),
      .got(m.get(.key(k1))),
      .exp(null)
    );
    chk(
      .what("k2 after missing delete"),
      .got(m.get(.key(k2))),
      .exp(v2)
    );

    // clear
    m.set(
      .key(k1),
      .obj(v1)
    );
    m.set(
      .key(k3),
      .obj(v3)
    );
    m.clear();
    chk(
      .what("clear k1"),
      .got(m.get(.key(k1))),
      .exp(null)
    );
    chk(
      .what("clear k2"),
      .got(m.get(.key(k2))),
      .exp(null)
    );
    chk(
      .what("clear k3"),
      .got(m.get(.key(k3))),
      .exp(null)
    );
    m.set(
      .key(k1),
      .obj(v3)
    );
    chk(
      .what("reuse after clear"),
      .got(m.get(.key(k1))),
      .exp(v3)
    );

    // two instances are independent
    m2.set(
      .key(k1),
      .obj(v1)
    );
    chk(
      .what("instance 2 k1"),
      .got(m2.get(.key(k1))),
      .exp(v1)
    );
    chk(
      .what("instance 1 unchanged"),
      .got(m.get(.key(k1))),
      .exp(v3)
    );
    m2.clear();
    chk(
      .what("clear instance 2"),
      .got(m2.get(.key(k1))),
      .exp(null)
    );
    chk(
      .what("instance 1 after clear 2"),
      .got(m.get(.key(k1))),
      .exp(v3)
    );

    // derived value comes back as the stored object
    m.clear();
    db = new(.name("db"));
    m.set(
      .key(k1),
      .obj(db)
    );
    r = m.get(.key(k1));
    chk(
      .what("derived value"),
      .got(r),
      .exp(db)
    );
    if ($cast(dgot, r)) begin
      n_chk++;
      if (dgot.tag == 7) begin
        `uvm_info("COPY_MAP",
                  $sformatf("PASS  %-26s tag=%0d", "cast back to derived", dgot.tag),
                  UVM_NONE)
      end
      else begin
        n_fail++;
        `uvm_error("COPY_MAP",
                   $sformatf("FAIL  cast back to derived tag=%0d", dgot.tag))
      end
    end
    else begin
      n_chk++;
      n_fail++;
      `uvm_error("COPY_MAP", "FAIL  cast back to derived: $cast failed")
    end

    // many entries
    m.clear();
    for (int i = 0; i < 20; i++) begin
      ks[i] = new(.name($sformatf("key%0d", i)));
      vs[i] = new(.name($sformatf("val%0d", i)));
      m.set(
        .key(ks[i]),
        .obj(vs[i])
      );
    end
    for (int i = 0; i < 20; i++) begin
      chk(
        .what($sformatf("many get %0d", i)),
        .got(m.get(.key(ks[i]))),
        .exp(vs[i])
      );
    end
    for (int i = 0; i < 20; i += 2) begin
      m.delete(.v(ks[i]));
    end
    for (int i = 0; i < 20; i++) begin
      if (i % 2 == 0) begin
        chk(
          .what($sformatf("many deleted %0d", i)),
          .got(m.get(.key(ks[i]))),
          .exp(null)
        );
      end
      else begin
        chk(
          .what($sformatf("many kept %0d", i)),
          .got(m.get(.key(ks[i]))),
          .exp(vs[i])
        );
      end
    end

    `uvm_info("COPY_MAP",
              $sformatf("COPY_MAP: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_copy_map

// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_packer.sv
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
// Direct test of uvm_packer (UVM 1.1d BCL class) and of uvm_object::pack,
// pack_bytes, pack_ints and the unpack methods. Part 1 uses the packer
// directly, part 2 packs objects through do_pack / do_unpack, part 3 goes
// through the uvm_object methods. Prints PASS or FAIL per check and a final
// summary line.
//
// Strings are packed with use_metadata set, so that a null byte ends them: the
// BCL unpack_string reports an error when the bits run out before it.
module t_packer;
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

    virtual function void do_pack(
      uvm_packer packer
    );
      super.do_pack(.packer(packer));
      packer.pack_field_int(
        .value(a),
        .size(32)
      );
      packer.pack_string(.value(s));
    endfunction : do_pack

    virtual function void do_unpack(
      uvm_packer packer
    );
      super.do_unpack(.packer(packer));
      a = packer.unpack_field_int(.size(32));
      s = packer.unpack_string();
    endfunction : do_unpack
  endclass : pkt_t

  // packs one bit, then itself: a cycle that the packer has to detect
  class cyc_t extends uvm_object;
    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function void do_pack(
      uvm_packer packer
    );
      super.do_pack(.packer(packer));
      packer.pack_field_int(
        .value(1),
        .size(1)
      );
      packer.pack_object(.value(this));
    endfunction : do_pack
  endclass : cyc_t

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("PACKER",
                $sformatf("PASS  %-34s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("PACKER",
                 $sformatf("FAIL  %-34s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("PACKER",
                $sformatf("PASS  %-34s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("PACKER",
                 $sformatf("FAIL  %-34s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  uvm_packer pk;
  pkt_t p1, p2, p3;
  cyc_t cy;
  uvm_bitstream_t w;
  uvm_bitstream_t r;
  bit unsigned pa[];
  bit unsigned gb[];
  byte unsigned pby[];
  byte unsigned gby[];
  int unsigned pin[];
  int unsigned gin[];
  bit bits[];
  byte unsigned by[];
  int unsigned ints[];
  int sz;

  initial begin
    pk = new;
    p1 = new(.name("p1"));
    p2 = new(.name("p2"));
    p3 = new(.name("p3"));
    cy = new(.name("cy"));

    // defaults
    chk_int(
      .what("default physical"),
      .got(pk.physical),
      .exp(1)
    );
    chk_int(
      .what("default abstract"),
      .got(pk.abstract),
      .exp(0)
    );
    chk_int(
      .what("default use_metadata"),
      .got(pk.use_metadata),
      .exp(0)
    );
    chk_int(
      .what("default big_endian"),
      .got(pk.big_endian),
      .exp(1)
    );
    chk_int(
      .what("default byte_size"),
      .got(pk.byte_size),
      .exp(8)
    );
    chk_int(
      .what("default word_size"),
      .got(pk.word_size),
      .exp(16)
    );
    chk_int(
      .what("default count"),
      .got(pk.count),
      .exp(0)
    );
    chk_int(
      .what("default packed size"),
      .got(pk.get_packed_size()),
      .exp(0)
    );

    // pack_field_int, big endian: the most significant bit comes first
    pk.pack_field_int(
      .value('h5),
      .size(4)
    );
    chk_int(
      .what("count after pack 4 bits"),
      .got(pk.count),
      .exp(4)
    );
    pk.set_packed_size();
    chk_int(
      .what("packed size 4"),
      .got(pk.get_packed_size()),
      .exp(4)
    );
    chk_int(
      .what("count reset by set_packed_size"),
      .got(pk.count),
      .exp(0)
    );
    chk_int(
      .what("big endian bit 0"),
      .got(pk.get_bit(.index(0))),
      .exp(0)
    );
    chk_int(
      .what("big endian bit 1"),
      .got(pk.get_bit(.index(1))),
      .exp(1)
    );
    chk_int(
      .what("big endian bit 2"),
      .got(pk.get_bit(.index(2))),
      .exp(0)
    );
    chk_int(
      .what("big endian bit 3"),
      .got(pk.get_bit(.index(3))),
      .exp(1)
    );
    chk_int(
      .what("unpack_field_int 4 bits"),
      .got(pk.unpack_field_int(.size(4))),
      .exp(5)
    );
    chk_int(
      .what("count after unpack"),
      .got(pk.count),
      .exp(4)
    );

    // little endian: the least significant bit comes first
    pk.reset();
    pk.big_endian = 0;
    pk.pack_field_int(
      .value('h5),
      .size(4)
    );
    pk.set_packed_size();
    chk_int(
      .what("little endian bit 0"),
      .got(pk.get_bit(.index(0))),
      .exp(1)
    );
    chk_int(
      .what("little endian bit 1"),
      .got(pk.get_bit(.index(1))),
      .exp(0)
    );
    chk_int(
      .what("little endian unpack"),
      .got(pk.unpack_field_int(.size(4))),
      .exp(5)
    );

    // several fields, then bytes and ints
    pk.reset();
    pk.big_endian = 1;
    pk.pack_field_int(
      .value('h12),
      .size(8)
    );
    pk.pack_field_int(
      .value('h34),
      .size(8)
    );
    pk.pack_field_int(
      .value('hDEADBEEF),
      .size(32)
    );
    pk.set_packed_size();
    chk_int(
      .what("packed size 48"),
      .got(pk.get_packed_size()),
      .exp(48)
    );
    pk.get_bytes(.bytes(gby));
    chk_int(
      .what("get_bytes size"),
      .got(gby.size()),
      .exp(6)
    );
    chk_int(
      .what("get_bytes byte 0"),
      .got(gby[0]),
      .exp('h12)
    );
    chk_int(
      .what("get_bytes byte 1"),
      .got(gby[1]),
      .exp('h34)
    );
    chk_int(
      .what("get_byte raw (bits reversed)"),
      .got(pk.get_byte(.index(0))),
      .exp('h48)
    );
    pk.get_ints(.ints(gin));
    chk_int(
      .what("get_ints size"),
      .got(gin.size()),
      .exp(2)
    );
    chk_int(
      .what("get_ints int 0 holds 1234DEAD"),
      .got(gin[0] == 32'h1234DEAD),
      .exp(1)
    );
    // the last, partly filled int is left aligned
    chk_int(
      .what("get_ints int 1 holds BEEF0000"),
      .got(gin[1] == 32'hBEEF0000),
      .exp(1)
    );
    chk_int(
      .what("unpack 8 bits"),
      .got(pk.unpack_field_int(.size(8))),
      .exp('h12)
    );
    chk_int(
      .what("unpack next 8 bits"),
      .got(pk.unpack_field_int(.size(8))),
      .exp('h34)
    );
    chk_int(
      .what("unpack 32 bits"),
      .got(pk.unpack_field_int(.size(32)) == 64'hDEADBEEF),
      .exp(1)
    );

    // put_bits, put_bytes, put_ints
    pa = new[4];
    pa[0] = 1;
    pa[1] = 0;
    pa[2] = 1;
    pa[3] = 1;
    pk.reset();
    pk.put_bits(.bitstream(pa));
    chk_int(
      .what("put_bits packed size"),
      .got(pk.get_packed_size()),
      .exp(4)
    );
    pk.get_bits(.bits(gb));
    chk_int(
      .what("get_bits size"),
      .got(gb.size()),
      .exp(4)
    );
    chk_int(
      .what("get_bits bit 2"),
      .got(gb[2]),
      .exp(1)
    );
    chk_int(
      .what("put_bits unpack"),
      .got(pk.unpack_field_int(.size(4))),
      .exp(11)
    );
    pby = new[2];
    pby[0] = 'h12;
    pby[1] = 'h34;
    pk.reset();
    pk.put_bytes(.bytestream(pby));
    chk_int(
      .what("put_bytes unpack 16 bits"),
      .got(pk.unpack_field_int(.size(16))),
      .exp('h1234)
    );
    pk.get_bytes(.bytes(gby));
    chk_int(
      .what("put_bytes get_bytes 1"),
      .got(gby[1]),
      .exp('h34)
    );
    pin = new[1];
    pin[0] = 32'hCAFEF00D;
    pk.reset();
    pk.put_ints(.intstream(pin));
    chk_int(
      .what("put_ints unpack 32 bits"),
      .got(pk.unpack_field_int(.size(32)) == 64'hCAFEF00D),
      .exp(1)
    );

    // pack_field above 64 bits
    w = 0;
    w[99] = 1;
    w[50] = 1;
    w[0] = 1;
    pk.reset();
    pk.pack_field(
      .value(w),
      .size(100)
    );
    pk.set_packed_size();
    chk_int(
      .what("pack_field 100 bits size"),
      .got(pk.get_packed_size()),
      .exp(100)
    );
    r = pk.unpack_field(.size(100));
    chk_int(
      .what("unpack_field bit 99"),
      .got(r[99]),
      .exp(1)
    );
    chk_int(
      .what("unpack_field bit 50"),
      .got(r[50]),
      .exp(1)
    );
    chk_int(
      .what("unpack_field bit 0"),
      .got(r[0]),
      .exp(1)
    );
    chk_int(
      .what("unpack_field bit 1"),
      .got(r[1]),
      .exp(0)
    );

    // time, real and string
    pk.reset();
    pk.pack_time(.value(1234));
    pk.pack_real(.value(2.5));
    pk.set_packed_size();
    chk_int(
      .what("time and real size"),
      .got(pk.get_packed_size()),
      .exp(128)
    );
    chk_int(
      .what("unpack_time"),
      .got(pk.unpack_time() == 1234),
      .exp(1)
    );
    chk_int(
      .what("unpack_real"),
      .got(pk.unpack_real() == 2.5),
      .exp(1)
    );
    pk.reset();
    pk.use_metadata = 1;
    pk.pack_string(.value("AB"));
    chk_int(
      .what("pack_string with null byte"),
      .got(pk.count),
      .exp(24)
    );
    pk.set_packed_size();
    chk_str(
      .what("unpack_string"),
      .got(pk.unpack_string()),
      .exp("AB")
    );
    chk_int(
      .what("count after unpack_string"),
      .got(pk.count),
      .exp(24)
    );

    // pack_object and unpack_object
    p1.a = 7;
    p1.s = "hi";
    pk.reset();
    pk.use_metadata = 1;
    pk.pack_object(.value(p1));
    chk_int(
      .what("pack_object bits"),
      .got(pk.count),
      .exp(60)
    );
    pk.set_packed_size();
    chk_int(
      .what("is_null for an object"),
      .got(pk.is_null()),
      .exp(0)
    );
    pk.unpack_object(.value(p2));
    chk_int(
      .what("unpack_object a"),
      .got(p2.a),
      .exp(7)
    );
    chk_str(
      .what("unpack_object s"),
      .got(p2.s),
      .exp("hi")
    );
    chk_int(
      .what("unpack_object count"),
      .got(pk.count),
      .exp(60)
    );
    pk.reset();
    pk.pack_object(.value(null));
    chk_int(
      .what("pack_object null bits"),
      .got(pk.count),
      .exp(4)
    );
    pk.set_packed_size();
    chk_int(
      .what("is_null for null"),
      .got(pk.is_null()),
      .exp(1)
    );
    pk.reset();
    pk.policy = UVM_REFERENCE;
    pk.pack_object(.value(p1));
    chk_int(
      .what("pack_object reference policy"),
      .got(pk.count),
      .exp(4)
    );
    pk.policy = UVM_DEFAULT_POLICY;

    // a cycle: the object packs itself
    pk.reset();
    pk.use_metadata = 0;
    pk.pack_object(.value(cy));
    chk_int(
      .what("cycle detected, one bit packed"),
      .got(pk.count),
      .exp(1)
    );
    pk.reset();
    chk_int(
      .what("reset clears count"),
      .got(pk.count),
      .exp(0)
    );

    // the uvm_object methods
    pk.use_metadata = 1;
    sz = p1.pack(
      .bitstream(bits),
      .packer(pk)
    );
    chk_int(
      .what("pack returns size"),
      .got(sz),
      .exp(56)
    );
    chk_int(
      .what("pack array size"),
      .got(bits.size()),
      .exp(56)
    );
    sz = p2.unpack(
      .bitstream(bits),
      .packer(pk)
    );
    chk_int(
      .what("unpack returns size"),
      .got(sz),
      .exp(56)
    );
    chk_int(
      .what("object unpack a"),
      .got(p2.a),
      .exp(7)
    );
    chk_str(
      .what("object unpack s"),
      .got(p2.s),
      .exp("hi")
    );
    sz = p1.pack_bytes(
      .bytestream(by),
      .packer(pk)
    );
    chk_int(
      .what("pack_bytes returns bits"),
      .got(sz),
      .exp(56)
    );
    chk_int(
      .what("pack_bytes array size"),
      .got(by.size()),
      .exp(7)
    );
    sz = p3.unpack_bytes(
      .bytestream(by),
      .packer(pk)
    );
    chk_int(
      .what("unpack_bytes a"),
      .got(p3.a),
      .exp(7)
    );
    chk_str(
      .what("unpack_bytes s"),
      .got(p3.s),
      .exp("hi")
    );
    sz = p1.pack_ints(
      .intstream(ints),
      .packer(pk)
    );
    chk_int(
      .what("pack_ints array size"),
      .got(ints.size()),
      .exp(2)
    );
    p2.a = 0;
    p2.s = "";
    sz = p2.unpack_ints(
      .intstream(ints),
      .packer(pk)
    );
    chk_int(
      .what("unpack_ints a"),
      .got(p2.a),
      .exp(7)
    );
    sz = p1.pack(.bitstream(bits));
    chk_int(
      .what("pack with the default packer"),
      .got(sz),
      .exp(48)
    );

    `uvm_info("PACKER",
              $sformatf("PACKER: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_packer

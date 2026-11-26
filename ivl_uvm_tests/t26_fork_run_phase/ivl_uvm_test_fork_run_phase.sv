// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_fork_run_phase.sv
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
////////////////////////////////////////////////////////////////////////
// Test of the forked run phase. A test has four children: three timed
// components (d10, d30, d20) that raise an objection, wait 10, 30 and 20 time
// units and drop it, and one ticker that loops forever and never raises an
// objection. With the run phases forked, all of them start at time 0 and
// run_test returns at time 30 (the longest delay), and the ticker is stopped
// at the end of the run phase. A thread the test itself forked before
// run_test (it sets a flag at time 50) must not be stopped by the end of the
// run phase. If the run phases run one after the other,
// the ticker blocks run_test and the test never prints its summary. All
// checks run after run_test has returned. Prints PASS or FAIL per check and
// a final summary line.
package fork_run_pkg;
  import ivl_uvm_pkg::*;

  string tr_start;
  int n_ticks;
  int n_ticks_later;
  int user_alive;
  int n_fail;
  int n_chk;

  class fork_timed extends uvm_component;
    `uvm_component_utils(fork_timed)
    int delay;

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(
        .obj(this)
      );
      tr_start = {tr_start, $sformatf("%0d ", $time)};
      #(delay);
      phase.drop_objection(
        .obj(this)
      );
    endtask : run_phase
  endclass : fork_timed

  // Loops forever and never raises an objection.
  class fork_ticker extends uvm_component;
    `uvm_component_utils(fork_ticker)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      tr_start = {tr_start, $sformatf("%0d ", $time)};
      forever begin
        #7;
        n_ticks++;
      end
    endtask : run_phase
  endclass : fork_ticker

  class fork_test extends uvm_test;
    `uvm_component_utils(fork_test)

    function new(
      string name,
      uvm_component parent
    );
      super.new(
        .name(name),
        .parent(parent)
      );
    endfunction : new

    function void build_phase(uvm_phase phase);
      fork_timed d10;
      fork_timed d30;
      fork_timed d20;
      fork_ticker tick;
      super.build_phase(phase);
      d10 = fork_timed::type_id::create(
        .name("d10"),
        .parent(this)
      );
      d10.delay = 10;
      d30 = fork_timed::type_id::create(
        .name("d30"),
        .parent(this)
      );
      d30.delay = 30;
      d20 = fork_timed::type_id::create(
        .name("d20"),
        .parent(this)
      );
      d20.delay = 20;
      tick = fork_ticker::type_id::create(
        .name("tick"),
        .parent(this)
      );
    endfunction : build_phase
  endclass : fork_test

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("FORK_RUN",
                $sformatf("PASS  %-20s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("FORK_RUN",
                 $sformatf("FAIL  %-20s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("FORK_RUN",
                $sformatf("PASS  %-20s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("FORK_RUN",
                 $sformatf("FAIL  %-20s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  // Called after run_test has returned, then again after a further delay.
  function void check_end(int end_time);
    chk_int(
      .what("run_test end time"),
      .got(end_time),
      .exp(30)
    );
    chk_str(
      .what("run phase starts"),
      .got(tr_start),
      .exp("0 0 0 0 ")
    );
    chk_int(
      .what("ticks by the end"),
      .got(n_ticks),
      .exp(4)
    );
  endfunction : check_end

  function void check_stopped();
    chk_int(
      .what("ticker stopped"),
      .got(n_ticks_later),
      .exp(4)
    );
    chk_int(
      .what("user thread alive"),
      .got(user_alive),
      .exp(1)
    );
    `uvm_info("FORK_RUN",
              $sformatf("FORK_RUN: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  endfunction : check_stopped
endpackage : fork_run_pkg

module t_fork_run;
  import ivl_uvm_pkg::*;
  import fork_run_pkg::*;

  initial begin
    // Forked by the test before run_test: the end of the run phase must not
    // stop it.
    fork
      begin
        #50;
        user_alive = 1;
      end
    join_none
    run_test(.test_name("fork_test"));
    check_end(
      .end_time($time)
    );
    #100;
    n_ticks_later = n_ticks;
    check_stopped();
  end
endmodule : t_fork_run

// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_semaphore.sv
// Authors: Srinivasan Venkataramanan, Ajeetha Kumari Venkatesan
// Copyright (c) 2026 AsFigo (https://www.asfigo.com)
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
class ivl_uvm_semaphore;

	int cur_key_count;

	function new (int keyCount = 0);
	  this.cur_key_count = keyCount;
	endfunction : new

	function void put (int keyCount = 1);
	  this.cur_key_count += keyCount;
	endfunction : put

	task get (int keyCount = 1);
	  while (this.cur_key_count < keyCount) begin
			#1;
	  end
	  this.cur_key_count -= keyCount;
	endtask : get

	function int try_get (int keyCount = 1);
		try_get = 0;
	  if (this.cur_key_count >= keyCount) begin
		  try_get = this.cur_key_count;
	    this.cur_key_count -= keyCount;
		end
	endfunction : try_get


endclass : ivl_uvm_semaphore

module t;
  ivl_uvm_semaphore sm_0;

	initial begin : test
		sm_0 = new(1);
		$display ("SM: cur_key: %0d", sm_0.cur_key_count);

	end : test
endmodule : t


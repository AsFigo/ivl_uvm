// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: uvm_scope_stack.svh
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
`ifndef IVL_UVM_SCOPE_STACK_SVH
`define IVL_UVM_SCOPE_STACK_SVH

//----------------------------------------------------------------------------
//
// CLASS- uvm_scope_stack
//
//----------------------------------------------------------------------------

class uvm_scope_stack;
  local string m_arg;
  local string m_stack[$];

  // Returns the number of scope levels on the stack.
  extern function int depth();

  // Returns the full scope: the levels joined by dots, then the argument.
  extern function string get();

  // Returns the scope argument (the last name component).
  extern function string get_arg();

  // Replaces the stack with the single level s and clears the argument.
  extern function void set (string s);

  // Pushes the level s and clears the argument.
  extern function void down (string s);

  // Pushes an array element level, written [element].
  extern function void down_element (int element);

  // Pops the element level if the top level is an element.
  extern function void up_element ();

  // Pops the top level, matching the separator, and clears the argument.
  extern function void up (byte separator =".");

  // Sets the scope argument to arg.
  extern function void set_arg (string arg);

  // Sets the scope argument to arg followed by [ele].
  extern function void set_arg_element (string arg, int ele);

  // Clears the scope argument when it equals arg.
  extern function void unset_arg (string arg);
endclass : uvm_scope_stack

function int uvm_scope_stack::depth();
  return m_stack.size();
endfunction : depth

function string uvm_scope_stack::get();
  string v;
  if(m_stack.size() == 0) begin
    return m_arg;
  end
  get = m_stack[0];
  for(int i=1; i<m_stack.size(); ++i) begin
    v = m_stack[i];
    if(v != "" && (v[0] == "[" || v[0] == "(" || v[0] == "{")) begin
      get = {get,v};
    end
    else begin
      get = {get,".",v};
    end
  end
  if(m_arg != "") begin
    if(get != "") begin
      get = {get, ".", m_arg};
    end
    else begin
      get = m_arg;
    end
  end
endfunction : get

function string uvm_scope_stack::get_arg();
  return m_arg;
endfunction : get_arg

function void uvm_scope_stack::set (string s);
  m_stack.delete();

  m_stack.push_back(s);
  m_arg = "";
endfunction : set

function void uvm_scope_stack::down (string s);
  m_stack.push_back(s);
  m_arg = "";
endfunction : down

function void uvm_scope_stack::down_element (int element);
  m_stack.push_back($sformatf("[%0d]",element));
  m_arg = "";
endfunction : down_element

function void uvm_scope_stack::up_element ();
  string s;
  if(!m_stack.size()) begin
    return;
  end
  s = m_stack.pop_back();
  if(s != "" && s[0] != "[") begin
    m_stack.push_back(s);
  end
endfunction : up_element

function void uvm_scope_stack::up (byte separator =".");
  bit found;
  string s;
  while(m_stack.size() && !found ) begin
    s = m_stack.pop_back();
    if(separator == ".") begin
      if (s == "" || (s[0] != "[" && s[0] != "(" && s[0] != "{")) begin
        found = 1;
      end
    end
    else begin
      if(s != "" && s[0] == separator) begin
        found = 1;
      end
    end
  end
  m_arg = "";
endfunction : up

function void uvm_scope_stack::set_arg (string arg);
  if(arg=="") begin
    return;
  end
  m_arg = arg;
endfunction : set_arg

function void uvm_scope_stack::set_arg_element (string arg, int ele);
  string tmp_value_str;
  tmp_value_str.itoa(ele);
  m_arg = {arg, "[", tmp_value_str, "]"};
endfunction : set_arg_element

function void uvm_scope_stack::unset_arg (string arg);
  if(arg == m_arg) begin
    m_arg = "";
  end
endfunction : unset_arg

`endif // IVL_UVM_SCOPE_STACK_SVH
`endif // IVL_UVM

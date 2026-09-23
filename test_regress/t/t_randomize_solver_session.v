// DESCRIPTION: Verilator: Verilog Test module
//
// Many back-to-back randomize() calls: plain, randc, soft, solve-before, array
// and unique constraints, followed by an unsatisfiable problem and a further
// successful call. Checks that the solver processes stay usable and that no
// state carries over between calls.
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026 Persimmons Inc.
// SPDX-License-Identifier: CC0-1.0

class Pkt;
  rand bit [7:0] addr;
  rand bit [15:0] len;
  rand bit [3:0] kind;
  randc bit [2:0] tag;
  rand bit [7:0] arr[4];
  rand bit [3:0] sel;
  constraint c_addr {
    addr inside {[8'h10 : 8'h7f]};
    addr % 4 == 0;
  }
  constraint c_len {
    len > 0;
    len <= 256;
    (kind == 0) -> len == 1;
  }
  constraint c_soft {soft kind == 2;}
  constraint c_arr {
    foreach (arr[i]) arr[i] > i;
    unique {arr};
  }
  constraint c_ord {solve kind before len;}
  constraint c_sel {
    sel < 4;
    arr[sel] != 8'hff;
  }
endclass

class Bad;
  rand bit [3:0] x;
  constraint c1 {x > 8;}
  constraint c2 {x < 4;}
endclass

module t;
  initial begin
    Pkt p;
    Bad b;
    int ok;
    int kind2;
    int tags[8];
    p = new;
    b = new;
    ok = 0;
    kind2 = 0;
    for (int i = 0; i < 64; i++) begin
      if (p.randomize()) ok++;
      if (!(p.addr inside {[8'h10 : 8'h7f]}) || p.addr % 4 != 0) $stop;
      if (p.len == 0 || p.len > 256 || (p.kind == 0 && p.len != 1)) $stop;
      foreach (p.arr[j]) if (p.arr[j] <= j) $stop;
      if (p.sel >= 4 || p.arr[p.sel] == 8'hff) $stop;
      tags[p.tag]++;
      if (p.kind == 2) kind2++;
    end
    if (ok != 64) $stop;
    // randc: 64 draws over 8 values
    foreach (tags[t]) if (tags[t] != 8) $stop;
    if (kind2 != 64) $stop;
    if (b.randomize()) $stop;
    // The session must still be usable after an unsatisfiable problem
    if (!p.randomize()) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule

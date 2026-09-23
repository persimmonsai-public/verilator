// DESCRIPTION: Verilator: Verilog Test module
//
// A task-local nested associative array written from inside a fork/join_none
// is moved to a dynamic scope; the write must still use the writable accessor
// (the rebuilt member select used to lose the write access, so the emitted
// C++ called the const `.at()` and failed to compile).
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026 Persimmons Inc.
// SPDX-License-Identifier: CC0-1.0

class sb;
  int entries;
  int cnt;
  bit finished;
  task run();
    bit done[int][logic [7:0]];
    logic [7:0] dst_id;
    fork
      begin
        for (int i = 0; i < 3; i++) begin
          #1;
          dst_id = 8'h5a + 8'(i);
          done[i][dst_id] = 1'b1;
          cnt++;
        end
        entries = done.size();
        finished = 1'b1;
      end
    join_none
  endtask
endclass

module t;
  initial begin
    sb s;
    s = new;
    s.run();
    wait (s.finished);
    if (s.entries != 3) $stop;
    if (s.cnt != 3) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule

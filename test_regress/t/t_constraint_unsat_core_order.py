#!/usr/bin/env python3
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either the GNU Lesser General Public License Version 3
# or the Perl Artistic License Version 2.0.
# SPDX-FileCopyrightText: 2026 Wilson Snyder
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

# The solver may list an unsat core in any order; UNSATCONSTR warnings must
# still follow source order. The tamper wrapper reverses the first core reply,
# and the output must match t_constraint_unsat.out exactly.

import vltest_bootstrap

test.scenarios('vlt')
test.top_filename = "t/t_constraint_unsat.v"

if not test.have_solver:
    test.skip("No constraint solver installed")

test.compile()

test.execute(expect_filename="t/t_constraint_unsat.out",
             run_env='VERILATOR_SOLVER="' + test.t_dir + '/randomize_solver_tamper.py" ' +
             'TAMPER=core_reverse TAMPER_AT=1 ')

test.passes()

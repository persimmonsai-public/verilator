#!/usr/bin/env python3
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either the GNU Lesser General Public License Version 3
# or the Perl Artistic License Version 2.0.
# SPDX-FileCopyrightText: 2026 Wilson Snyder
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

# After each transaction's (reset) the runtime sends z3 a throwaway declaration
# so z3 rebuilds its context while the simulation runs. It must be sent to z3
# only: a solver with another name (here the tamper wrapper forwarding to a real
# solver) must never see it, and results must not depend on it.

import shutil

import vltest_bootstrap

test.scenarios('vlt')
test.top_filename = "t/t_randomize_solver_session.v"

if not test.have_solver:
    test.skip("No constraint solver installed")

test.compile(verilator_flags2=["-Wno-WIDTH"])

if shutil.which('z3'):
    z3_log = test.obj_dir + '/solver_z3.log'
    test.execute(logfile=test.obj_dir + '/sim_z3.log',
                 all_run_flags=['+verilator+solver+file+' + z3_log],
                 run_env='VERILATOR_SOLVER="z3 --in" ')
    test.file_grep(z3_log, r'\(declare-const __Vsolver_warm Bool\)')

other_log = test.obj_dir + '/solver_other.log'
test.execute(logfile=test.obj_dir + '/sim_other.log',
             all_run_flags=['+verilator+solver+file+' + other_log],
             run_env='VERILATOR_SOLVER="' + test.t_dir + '/randomize_solver_tamper.py" ' +
             'TAMPER=none ')
test.file_grep_not(other_log, r'__Vsolver_warm')

test.passes()

# DSD-8 Processor

Verilog implementation of the DSD-8 8-bit Harvard processor described
in the supplied project specification. The ISA and module interfaces
are fixed by that specification; the CPU uses a multi-cycle controller
with fetch, execute, I/O-wait, and halted states.

## What's here

```
rtl/        processor datapath, controller, memories, I/O bus, and board top
tb/         tb_dsd8.v (the supplied conformance harness, do not edit)
            + self-checking module, peripheral, and integration testbenches
sim/        instructor-supplied reference peripheral models (UART, timer, SLOW_ECHO)
tools/      dsd8asm.py (assembler) and dsd8sim.py (golden reference simulator)
tests/conformance/   worked examples, smoke coverage, and local T01-T40 programs
scripts/    run_conformance.py, run_unit_tests.py, lint.sh, install_hooks.sh
doc/        completed design report / verification report / bug log
.github/    CI workflows, CODEOWNERS, PR and issue templates
```

## Quick start

```
git clone <your-team's-repo-url>
cd <repo>
./scripts/install_hooks.sh      # certify locally before every push
make lint                       # verilator --lint-only (needs verilator)
make test                       # every tb/tb_*.v unit testbench (needs iverilog)
make conformance                # tests/conformance/*.asm end to end
```

Run `python scripts/run_unit_tests.py` and `python scripts/run_conformance.py`
on Windows when Icarus Verilog and Python are on `PATH`. The equivalent
Makefile targets are available on systems with `make`; lint additionally
requires Verilator.

## RTL lint

Verilator lint statically checks the Verilog without running a simulation.
It can catch issues such as inferred latches, width mismatches, and unused
signals. It complements (but does not replace) the Icarus simulations.

On this Windows machine, Verilator 5.050 is installed under
`%USERPROFILE%\msys64`; its launcher and runtime are on the user `PATH`,
and `VERILATOR_ROOT` points to its data files. Open a new terminal if
those environment changes are not visible in an existing one. In Windows
PowerShell, from the repository root, run:

```powershell
$rtl = Get-ChildItem rtl\*.v | ForEach-Object { $_.FullName }
verilator --lint-only -Wall --top-module dsd8_top $rtl
```

The same check is run by `scripts/lint.sh` in a Bash environment (for
example Git Bash or WSL). The Makefile's `lint` target invokes that script.

The conformance runner executes the two worked examples, `smoke_isa`, and
the local `t01_...` through `t40_...` programs. The local suite exercises
all six specification groups, including the delayed SLOW_ECHO handshake.
It is a transparent local implementation of the requirements, not the
instructor's private authoritative golden suite.

The data RAM has no reset port in the frozen interface, so its bytes are
initialized to zero at simulation/FPGA initialization, as permitted by
the specification. The board top wires switches, buttons, LEDs, and the
seven-segment display; UART, timer, and SLOW_ECHO models are exercised by
the simulation integration benches.

## The four things this template gives you that the spec describes but
## does not hand you the source of

1. **`tools/dsd8asm.py` / `tools/dsd8sim.py`** -- a real assembler and
   golden reference simulator implementing the full ISA (Sections 2-3),
   verified against the two fully-specified worked examples in
   Appendix B. This is what `dsd8sim.py` means everywhere the spec
   refers to "the reference simulator."
2. **`tb/tb_dsd8.v`** -- the harness described in Section 8.3, wired to
   `dsd8_cpu` + `instr_memory` + `io_bus` and emitting the exact
   ten-field trace format from Section 8.2.
3. **`sim/peripherals.v`** -- the reference UART/timer/SLOW_ECHO models
   Section 7.2 says are supplied, so a peripheral bug is never mistaken
   for a CPU bug (with two documented simplifications -- see the file).
4. **`scripts/run_conformance.py`** -- diffs your trace against the
   golden one and reports the first differing line, which is the whole
   verification methodology in Section 8.1 as one command.

See the READMEs in `tb/` and `tests/conformance/`, plus the completed
reports in `doc/`, for verification details.

## Workflow, in one paragraph

Branch per module or feature, PR into `main`, CI lints and unit-tests
on every push (conformance reports but doesn't gate), your module's
owner approves via CODEOWNERS, merge. At each milestone deadline, tag
the commit (`git tag m3 && git push --tags`) -- grading always reads
the tagged commit, and pushing a milestone tag makes conformance
authoritative for that ref. Full detail in `CONTRIBUTING.md`.

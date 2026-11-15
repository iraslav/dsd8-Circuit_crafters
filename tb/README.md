# tb/ -- testbenches

## `tb_dsd8.v` -- the conformance harness

This is "the supplied harness" from Section 8.3 of the spec. It is run
by `scripts/run_conformance.py`, not by hand, and you do not modify it
-- everyone is graded against the same file. See the comments at the
top of `tb_dsd8.v` for exactly what it wires up.

## Your own unit testbenches (Section 8.5, R24)

The self-checking benches cover the ALU, controller, PC, decoder,
register file, flags register, data memory, instruction memory, and I/O
bus. The end-to-end conformance programs exercise the integrated CPU and
its retirement trace. `dsd8_top` is compile-checked; board-specific
hardware behavior is outside this software project. Each bench follows
the same self-checking pattern:

1. Instantiate the DUT.
2. Compute the expected result **independently** -- do not copy the
   DUT's own logic into the testbench, or a bug you make once will
   agree with itself twice.
3. Apply a set of vectors (directed for a first pass; the ALU
   additionally needs a **constrained-random** loop of at least 10,000
   operand pairs per R24, covering the corner-case operands in R25).
4. Count mismatches and print a final line:
   `TESTBENCH: PASS` or `TESTBENCH: FAIL (N errors)`.

`scripts/run_unit_tests.py` looks for those two exact strings on
stdout -- keep the convention in every testbench you add, and name
files `tb_<module>.v` so the script finds them automatically.

`tb_alu_example.v` runs 10,000 random operand pairs across the eight
operations and reports coverage of the five required corner values in
both operand positions.

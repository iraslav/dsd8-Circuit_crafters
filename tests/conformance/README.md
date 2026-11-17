# tests/conformance/

`sample01_multiply.asm` and `sample02_popcount.asm` are the two fully
deterministic worked examples from the spec's Appendix B (B.1 and
B.2) -- no I/O, no preloaded data memory, so their expected results
are unambiguous. Both are verified here: assembling and
running them through `tools/dsd8sim.py` reproduces the documented
final state exactly (R3 = 91 / LEDs = 0x5B / 51 instructions for the
multiply; R2 = 6 / 44 instructions for the population count).

`smoke_isa.asm` is an additional directed integration program covering
the arithmetic/logic operations, flag branches, data memory, I/O ports,
and SLOW_ECHO wait handshake.

The `t01_...asm` through `t40_...asm` files are a local, deterministic
implementation of the six T01-T40 coverage groups from Section 8.4.
They are intentionally readable and run through the same assembler,
golden simulator, RTL harness, and trace diff. They are not a claim to
be the instructor's private golden files; if those are supplied, place
them alongside these programs and run them separately.

The sample programs are also retained because they are the two worked
examples from Appendix B. What these programs are for:

- proving the processor works end to end (assemble -> golden trace ->
  RTL simulation -> diff),
- giving every team something to point `make conformance` at from day
  one,
- being a second sanity check on `tools/dsd8asm.py` and
  `tools/dsd8sim.py` themselves, independent of the appendix B.3
  (bubble sort, needs a preloaded data memory) and B.4 (UART echo,
  needs timed stimulus) examples that are covered separately by the
  UART integration bench.

When the instructor's real T01-T40 suite is distributed, keep its
`.asm` files and golden `.trace` files in a separate directory or use a
separate filter so that its authoritative expected traces are not
confused with this local executable coverage suite.

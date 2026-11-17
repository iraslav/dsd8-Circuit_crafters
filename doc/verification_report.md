# DSD-8 Verification Report

## 1. Verification plan

Verification follows the project specification: lint the complete RTL,
run self-checking module benches, compare assembled programs against the
golden Python simulator, and exercise delayed and injected peripherals.
The local suite contains the two worked examples, the directed ISA smoke
program, and forty deterministic `t01_...` through `t40_...` programs
organized across the six specification groups.

## 2. Current evidence

| Check | Result |
|---|---:|
| Verilator lint of `dsd8_top` hierarchy | PASS |
| Self-checking Verilog benches | 13 / 13 PASS |
| Local conformance programs | 43 / 43 PASS |
| ALU random vectors | 10,000 plus directed vectors |
| ALU corner coverage | All five required values seen as both operands |
| UART RX polling and TX echo integration | PASS |
| SLOW_ECHO delayed handshake | PASS |

The runner treats compiler failures and simulator non-zero exits as errors.
The conformance runner reports the first trace difference and returns a
non-zero exit status if any program differs.

## 3. Unit-test coverage

The benches under `tb/` cover every required module either directly or
through a dedicated integration bench:

| Area | Bench | Coverage |
|---|---|---|
| ALU | `tb_alu_example.v` | All eight operations, flags, 10,000 random pairs, corners |
| Control | `tb_control_unit.v` | All opcodes, branch conditions, I/O wait, HLT |
| Data memory | `tb_data_memory.v` | Zero initialization, write/read, independent addresses |
| Decoder/PC/registers/flags/memory | `tb_datapath.v` plus dedicated benches | Reset, field overlaps, routing, hold/update behavior |
| I/O bus | `tb_io_bus.v` | Board ports, unmapped ports, peripheral forwarding and ready |
| Reference peripherals | `tb_peripherals.v` | UART TX, injected RX/status/clear, timer path, SLOW_ECHO |
| CPU core | `tb_dsd8_cpu.v` | Fetch, LDI retirement, HLT, retirement count |
| Board top | `tb_dsd8_top.v` | Reset outputs and top-level integration |
| CPU + UART | `tb_uart_integration.v` | Polled RX, CPU read, UART TX echo, halt |

## 4. ALU random and coverage evidence

`tb_alu_example.v` uses an independent behavioral model and executes 10,000
constrained-random operand pairs distributed across ADD, SUB, AND, OR, XOR,
SHL, SHR, and CMP. Directed vectors cover arithmetic boundaries and the
required corner values. The test prints:

```text
ALU corner coverage A=11111 B=11111
TESTBENCH: PASS
```

The five bits correspond to `0x00`, `0x01`, `0x7F`, `0x80`, and `0xFF`.
The evidence confirms each value occurred as both ALU operands.

## 5. Conformance coverage

The forty local programs map to the specification groups:

- T01-T08: register movement, immediates, NOP, and read-after-write behavior.
- T09-T14: zeroed memory, edge addresses, address routing, and LD flags.
- T15-T22: arithmetic flags, carry/borrow, overflow, logic, shifts, CMP.
- T23-T30: jumps, all branch conditions, flag preservation, ordering, loops.
- T31-T35: board I/O, unmapped ports, independent memory/I/O, SLOW_ECHO.
- T36-T40: multiply, population count, memory sorting/min/max, UART path.

These are locally authored deterministic tests and are not a replacement for
an instructor-provided confidential T01-T40 golden suite if that suite is
later supplied. They do provide executable coverage for every requirement.

## 6. Peripheral and UART evidence

The reference peripheral model now supports deterministic RX injection,
UART status, RX read-clear behavior, TX event/data capture, timer control,
and SLOW_ECHO delays. `tb_uart_integration.v` injects `0x5A`, polls
`UART_STATUS`, reads `UART_RX`, writes `UART_TX`, and checks that the
transmitted byte is `0x5A`.

## 7. Remaining risk and closure

The implementation is lint-clean and passes all local executable checks.
The remaining external risk is hardware-specific synthesis and board timing,
because these tests run in Icarus/Verilator simulation. The instructor's
private grading suite, if distributed separately, must still be run before
claiming official grading conformance. A physical UART stimulus and FPGA
pin-level demonstration are also outside this repository's simulator scope.


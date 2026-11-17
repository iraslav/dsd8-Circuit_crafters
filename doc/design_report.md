# DSD-8 Design Report

## 1. Scope and architecture

This repository implements the frozen DSD-8 8-bit Harvard processor from the
project specification. The machine has eight 8-bit registers, a 9-bit program
counter, 512 words of 16-bit instruction memory, 256 bytes of data memory,
four architectural flags, and a separate 256-port I/O address space.

The implementation uses a multi-cycle controller. Each ordinary instruction
has a FETCH cycle followed by an EXECUTE cycle. I/O instructions enter
`IO_WAIT` and hold their request, port, and write data stable until
`io_ready` is observed. HLT retires once and then remains in HALTED without
changing architectural state. Decode is combinational and is performed from
the instruction word supplied by instruction memory.

## 2. Module hierarchy

The required module names and frozen interfaces are present:

| Module | Responsibility |
|---|---|
| `dsd8_top` | Board-level clock/reset, CPU, instruction memory, and board I/O |
| `dsd8_cpu` | Datapath integration, writeback, retirement outputs |
| `prog_counter` | 9-bit increment/load/hold PC |
| `instr_memory` | 512 x 16 `$readmemh` instruction image |
| `instr_decoder` | Combinational field extraction |
| `register_file` | Eight registers, two combinational reads, one write |
| `alu` | Arithmetic, logic, shifts, and Z/N/C/V generation |
| `flags_reg` | Architectural flag storage and reset |
| `data_memory` | 256 x 8 combinational-read/write memory |
| `control_unit` | FETCH, EXECUTE, IO_WAIT, and HALTED sequencing |
| `io_bus` | Board-port decode and peripheral handshake forwarding |

## 3. Control and datapath decisions

1. **Multi-cycle FSM:** A two-cycle ordinary instruction path was selected
   instead of a long single-cycle path. This makes retirement and the I/O
   stall behavior directly observable.
2. **Combinational instruction memory read:** The fixed interface permits the
   instruction word to be available from the current PC without an extra
   registered-memory state.
3. **Single ALU operation encoding:** The instruction opcode is passed
   directly to the ALU, avoiding an unnecessary second opcode encoding.
4. **Shared subtract adder:** ADD, SUB, and CMP use the same 9-bit
   `{carry,result} = a + (~b) + 1` path for the specified no-borrow carry
   convention.
5. **Explicit operand routing:** ST and OUT select their data operand from
   the instruction's `rd` field, while the address/source remains on the
   first read port. This follows the format-M and format-P asymmetry.
6. **Dedicated I/O wait state:** I/O requests are asserted only in IO_WAIT
   and remain active until ready. No register, flag, memory, or PC update
   occurs while stalled.
7. **Initial data-memory clearing:** The frozen `data_memory` interface has
   no reset port. Its complete array is initialized to zero at simulation and
   FPGA initialization, matching the required reset-visible state.

## 4. Retirement and trace

The CPU emits exactly one retirement pulse for each completed instruction,
including HLT. The retirement outputs provide the PC, instruction word,
register writeback, memory write, and post-instruction flags. The supplied
testbench formats those signals into the ten-field trace required by the
specification.

## 5. I/O architecture

Ports `0x00` and `0x01` read switches and buttons. Ports `0x02`, `0x10`, and
`0x11` latch LEDs and seven-segment outputs. Ports at and above `0x20` are
forwarded to the reference UART, timer, and SLOW_ECHO simulation peripherals.
Unmapped ports return zero, discard writes, and complete immediately.

## 6. Review questions

- `flags_we` is selected in EXECUTE for ADD, SUB, AND, OR, XOR, SHL, SHR,
  and CMP only.
- CMP asserts `flags_we` but not `rf_we`.
- A low `io_ready` leaves the controller in IO_WAIT and holds the request.
- HLT sets the controller state to HALTED; the PC has no enable and all
  write controls are deasserted.


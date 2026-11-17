; Local deterministic coverage for the DSD-8 specification.
JMP TARGET
LDI R1, 0xEE
TARGET: LDI R1, 0x2A
JMP DONE
LDI R1, 0xDD
DONE: HLT

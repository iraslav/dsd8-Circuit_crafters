; Local deterministic coverage for the DSD-8 specification.
LDI R1, 1
LDI R2, 1
CMP R1, R2
LDI R3, 0x40
LD R4, [R3]
BEQ GOOD
LDI R5, 0xEE
GOOD: HLT

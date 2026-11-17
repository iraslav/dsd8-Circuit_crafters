; Local deterministic coverage for the DSD-8 specification.
LDI R1, 5
LDI R2, 5
LDI R3, 0xAA
CMP R1, R2
BEQ SAME
LDI R3, 0xEE
SAME: HLT

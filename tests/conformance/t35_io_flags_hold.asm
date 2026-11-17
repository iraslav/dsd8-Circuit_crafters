; Local deterministic coverage for the DSD-8 specification.
LDI R1, 1
LDI R2, 1
CMP R1, R2
IN R3, 0x00
OUT 0x02, R3
BEQ GOOD
LDI R4, 0xEE
GOOD: HLT

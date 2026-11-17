; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x7F
LDI R2, 0x80
CMP R1, R2
BCC LESS
LDI R3, 0xEE
LESS: HLT

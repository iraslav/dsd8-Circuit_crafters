; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0xF0
LDI R2, 0x0F
AND R3, R1, R2
OR R3, R1, R2
XOR R3, R1, R2
HLT

; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x80
LDI R2, 0xFF
SHR R3, R1
AND R4, R3, R2
HLT

; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x5A
OUT 0x40, R1
IN R2, 0x40
OUT 0x02, R2
HLT

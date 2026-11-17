; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x41
OUT 0x20, R1
IN R2, 0x22
OUT 0x02, R2
HLT

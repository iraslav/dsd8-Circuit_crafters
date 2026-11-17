; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x22
LDI R2, 0xA5
ST [R1], R2
OUT 0x02, R2
LD R3, [R1]
IN R4, 0x00
HLT

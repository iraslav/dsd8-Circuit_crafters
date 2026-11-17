; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x20
LDI R2, 0x77
ST [R1], R2
LDI R3, 0x20
LD R4, [R3]
HLT

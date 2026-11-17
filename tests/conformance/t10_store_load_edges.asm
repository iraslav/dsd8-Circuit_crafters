; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0
LDI R2, 0x12
ST [R1], R2
LDI R1, 0xFF
LDI R2, 0xED
ST [R1], R2
LD R3, [R1]
HLT

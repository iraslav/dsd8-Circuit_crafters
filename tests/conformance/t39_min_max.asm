; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x20
LDI R2, 0x3A
ST [R1], R2
LDI R1, 0x21
LDI R2, 0x11
ST [R1], R2
LDI R1, 0x22
LDI R2, 0xF0
ST [R1], R2
LDI R1, 0x20
LD R3, [R1]
LDI R1, 0x21
LD R4, [R1]
CMP R3, R4
BCS KEEP_MAX
MOV R3, R4
KEEP_MAX: HLT

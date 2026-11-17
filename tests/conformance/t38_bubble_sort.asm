; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x10
LDI R2, 3
LDI R3, 9
ST [R1], R3
LDI R1, 0x11
LDI R3, 2
ST [R1], R3
LDI R1, 0x12
LDI R3, 7
ST [R1], R3
LDI R1, 0x10
LD R4, [R1]
LDI R1, 0x11
LD R5, [R1]
CMP R4, R5
BCC SWAP
JMP DONE
SWAP: ST [R1], R4
LDI R1, 0x10
ST [R1], R5
DONE: HLT

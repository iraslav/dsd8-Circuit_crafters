; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x7F
LDI R2, 1
ADD R3, R1, R2
BVS GOOD
LDI R4, 0xEE
GOOD: HLT

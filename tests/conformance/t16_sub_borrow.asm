; Local deterministic coverage for the DSD-8 specification.
LDI R1, 1
LDI R2, 2
SUB R3, R1, R2
BCC BORROW
LDI R4, 0xEE
BORROW: HLT

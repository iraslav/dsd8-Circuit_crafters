; Local deterministic coverage for the DSD-8 specification.
LDI R1, 2
LDI R2, 2
CMP R1, R2
BEQ ONE
ONE: BEQ TWO
TWO: HLT

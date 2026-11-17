; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0x80
LDI R2, 0x7F
CMP R1, R2
BMI NEG
NEG: BVS DONE
DONE: HLT

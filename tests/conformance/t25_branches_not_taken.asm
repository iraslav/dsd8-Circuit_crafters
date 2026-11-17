; Local deterministic coverage for the DSD-8 specification.
LDI R1, 1
LDI R2, 1
CMP R1, R2
BNE SKIP1
SKIP1: BCC SKIP2
SKIP2: BMI SKIP3
SKIP3: BVS SKIP4
SKIP4: HLT

; Local deterministic coverage for the DSD-8 specification.
LDI R1, 1
LDI R2, 1
CMP R1, R2
BEQ B1
B1: BNE B2
B2: BCS B3
B3: BCC B4
B4: BMI B5
B5: BPL B6
B6: BVS B7
B7: BVC DONE
DONE: HLT

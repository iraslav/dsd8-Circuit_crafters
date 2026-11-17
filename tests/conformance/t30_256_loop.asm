; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0
LDI R2, 1
LDI R3, 0
LOOP: ADD R1, R1, R2
ADD R3, R3, R2
BNE LOOP
HLT

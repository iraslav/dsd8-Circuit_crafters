; Local deterministic coverage for the DSD-8 specification.
LDI R1, 6
LDI R2, 7
LDI R3, 0
LDI R4, 1
LOOP: CMP R2, R0
BEQ DONE
ADD R3, R3, R1
SUB R2, R2, R4
JMP LOOP
DONE: OUT 0x02, R3
HLT

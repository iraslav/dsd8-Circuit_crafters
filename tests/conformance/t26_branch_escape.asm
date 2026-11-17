; Local deterministic coverage for the DSD-8 specification.
LDI R1, 1
LOOP: SUB R1, R1, R1
BEQ DONE
JMP LOOP
DONE: HLT

; Local deterministic coverage for the DSD-8 specification.
LDI R1, 0
LDI R2, 1
LDI R3, 0xAA
LOOP: ST [R1], R3
ADD R1, R1, R2
CMP R1, R2
BNE LOOP
LD R4, [R1]
HLT

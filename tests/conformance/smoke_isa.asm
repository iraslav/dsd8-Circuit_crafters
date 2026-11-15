; Directed integration smoke test for ISA operations and I/O handshaking.
LDI R0, 0xFF
LDI R1, 0x01
ADD R2, R0, R1
BEQ zero_result
LDI R3, 0xEE

zero_result:
SUB R3, R0, R1
BCS no_borrow
NOP

no_borrow:
BCC fail
BMI negative
NOP

negative:
BPL fail
LDI R4, 0x7F
LDI R5, 0x01
ADD R6, R4, R5
BVS overflow
NOP

overflow:
BVC fail
CMP R1, R0
BCC borrow
NOP

borrow:
BCS fail
BPL positive
NOP

positive:
BMI fail
BVC no_overflow
NOP

no_overflow:
BVS fail
BNE not_equal
NOP

not_equal:
BEQ fail
CMP R1, R1
BEQ equal
BNE fail

equal:
AND R2, R0, R1
OR R2, R0, R1
XOR R2, R0, R0
SHL R2, R0
SHR R2, R2
CMP R0, R1
LDI R6, 0x40
ST [R6], R3
LD R7, [R6]
IN R4, 0x00
OUT 0x02, R7
OUT 0x40, R7
IN R5, 0x40
IN R6, 0x7F
OUT 0x7F, R6
BCS io_flags_unchanged
JMP fail

io_flags_unchanged:
JMP done

fail:
LDI R7, 0xEE

done:
NOP
HLT

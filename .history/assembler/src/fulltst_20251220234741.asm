; ============================
;  TEST: ZERO-OPERAND INSTRUCTIONS
; ============================
NOP
HLT
SETC
RET
RTI

; ============================
;  TEST: ONE-REGISTER (SRC)
; ============================
PUSH R1
OUT R7
INC R3
NOT R1

; ============================
;  TEST: ONE-REGISTER (DST)
; ============================
POP R2
IN R4

; ============================
;  TEST: MOV, SWAP
; ============================
MOV R1, R2
SWAP R3, R4

; ============================
;  TEST: ALU — 3 REGISTERS
; ============================
ADD R1, R1, R2
SUB R3, R4, R5
AND R6, R7, R1

; ============================
;  TEST: LDM (IMM 32-bit)
; ============================
LDM R0, 5
LDM R1, -3
LDM R2, 0x10
LDM R3, 0b1011
LDM R4, -0xFF
LDM R5, -0b10000

; ============================
;  TEST: IADD (REG + IMM)
; ============================
IADD R1, R2, 7
IADD R3, R4, -1
IADD R5, R6, 0xABC
IADD R7, R0, -0b1111

; ============================
;  TEST: JUMPS / CALL / INT  (IMM ONLY)
; ============================
JZ 10
JN -5
JC 0x40
JMP 0b110
CALL -200
INT 1000

; ============================
;  TEST: MEMORY INSTRUCTIONS LDD / STD
; ============================
LDD R0, 12(R1)
LDD R2, -4(R3)
LDD R4, 0x20(R6)
LDD R7, 0b101(R5)

STD R1, 8(R2)
STD R3, -16(R4)
STD R5, 0x30(R7)
STD R0, 0b1000(R6)

; ============================
; ----------- INVALID TESTS ------------
; Uncomment to verify assembler error messages
; =======================================

;INVALID: wrong register name
;MOV RA, R1

;INVALID: immediate wrong format
;LDM R0, 4A

;INVALID: missing register
;ADD R1, R2

;INVALID: bad offset syntax
;LDD R1, 5R2)

;INVALID: register out of range
;INC R8

;INVALID: stray extra operand
;MOV R1, R2, R3

;INVALID: too few operands
;IADD R1, R2

;INVALID: missing comma
;MOV R1 R2

;INVALID: immediate missing
;CALL


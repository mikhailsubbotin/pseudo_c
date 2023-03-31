; PSEUDO_C_COMPATIBILITY_WIN9X equ TRUE
; PSEUDO_C_USE_ONLY_WINAPI equ TRUE

PSEUDO_C_INSTRUCTIONS_ALIGN = 16

; cmovz and etc. :
PSEUDO_C_INSTRUCTION_CMOVcc equ FALSE

; jcxz / jecxz :
PSEUDO_C_INSTRUCTION_JECXZ equ TRUE

; cmpsb / cmpsw / cmpsd / lodsb / lodsw / lodsd / movsb / movsw / movsd / scasb / scasw / scasd / stosb / stosw / stosd :
PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET equ TRUE

; Streaming SIMD Extensions 2 :
; PSEUDO_C_SSE2_INSTRUCTION_SET equ FALSE

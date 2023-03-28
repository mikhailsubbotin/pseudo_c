; Pseudo C / math.asm
; -------------------
; 06.06.2021 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_abs

_val = 4

        mov     eax, [esp+_val]
        cdq
        xor     eax, edx
        sub     eax, edx
        retn
endp

c_labs equ c_abs

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_div

_num = 4
_den = 8

        mov     eax, [esp+_num]
        cdq
        idiv    dword [esp+_den]
        retn
endp

c_ldiv equ c_div

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_rotl

_val = 4
_sft = 8

        mov     ecx, [esp+_sft]
        mov     eax, [esp+_val]
        and     ecx, 11111b
        rol     eax, cl
        retn
endp

c_lrotl equ c_rotl

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_rotr

_val = 4
_sft = 8

        mov     ecx, [esp+_sft]
        mov     eax, [esp+_val]
        and     ecx, 11111b
        ror     eax, cl
        retn
endp

c_lrotr equ c_rotr

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc allmul

_a = 4 ; qword
_b = 12 ; qword

        mov     eax, [esp+_a+4]
        mov     ecx, [esp+_b+4]
        or      ecx, eax
        mov     ecx, [esp+_b]
        jnz     @f
        mov     eax, [esp+_a]
        mul     ecx
        retn    16

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        push    ebx
        mul     ecx
        mov     ebx, eax
        mov     eax, [esp+4+_a]
        mul     dword [esp+4+_b+4]
        add     ebx, eax
        mov     eax, [esp+4+_a]
        mul     ecx
        add     edx, ebx
        pop     ebx
        retn    16
endp

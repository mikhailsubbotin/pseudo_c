; Pseudo C / processor.asm
; ------------------------
; 14.05.2020 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc is_cpuid_instruction_supported
        push    ebx
        pushfd
        pop     eax
        mov     ebx, eax
        xor     eax, 1 shl 21
        push    eax
        popfd
        pushfd
        pop     eax
        xor     eax, ebx
        setnz   al
        movzx   eax, al
        pop     ebx
        retn
endp

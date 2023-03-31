; Pseudo C / processor.asm
; ------------------------
; 28.03.2023 © Mikhail Subbotin

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

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc is_intel_processor_behaviour
        push    ebx
        xor     edx, edx
        mov     eax, 5
        mov     ebx, 2
        div     ebx
        pop     ebx
        setnz   al
        retn
endp

; Pseudo C / system.asm
; ---------------------
; 10.12.2020 © Mikhail Subbotin

;        call    IsWow64
;        test    eax, eax
;        js      .error
;        jnz     .wow_64

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc IsWow64
        invoke  GetModuleHandle, .KERNEL32.DLL
        test    eax, eax
        jz      .error
        invoke  GetProcAddress, eax, .IsWow64Process
        test    eax, eax
        jz      .error_is_call_not_implemented
        push    FALSE
        stdcall eax, -1, esp ; -1 = GetCurrentProcess
        test    eax, eax
        jz      .restore_stack_and_return
        pop     eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.error:
        mov     eax, 1 shl 31
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_is_call_not_implemented:
        invoke  GetLastError
        cmp     eax, ERROR_CALL_NOT_IMPLEMENTED
        jnz     .error
        invoke  SetLastError, ERROR_SUCCESS
        xor     eax, eax ; FALSE
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.restore_stack_and_return:
        add     esp, 4
        retn

align PSEUDO_C_INSTRUCTIONS_ALIGN

.KERNEL32.DLL TCHAR 'KERNEL32.DLL', 0
align 4
.IsWow64Process db 'IsWow64Process', 0

endp

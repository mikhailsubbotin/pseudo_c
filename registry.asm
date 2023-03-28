; Pseudo C / registry.asm
; -----------------------
; 10.05.2020 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc RegGetValueLengthA

_hKey = 4
_lpValueName = 8

__registry_value_length = 0

        xor     eax, eax
        push    eax
        invoke  RegQueryValueExA, dword [esp+20+4+_hKey], dword [esp+16+4+_lpValueName], eax, eax, eax, esp
        test    eax, eax
        jnz     .return_error_code
        mov     eax, [esp+__registry_value_length]

.restore_stack_and_return:
        add     esp, 4
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  SetLastError, eax
        mov     eax, -1
        jmp     .restore_stack_and_return
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc RegGetValueLengthW

_hKey = 4
_lpValueName = 8

__registry_value_length = 0

        xor     eax, eax
        push    eax
        invoke  RegQueryValueExW, dword [esp+20+4+_hKey], dword [esp+16+4+_lpValueName], eax, eax, eax, esp
        test    eax, eax
        jnz     .return_error_code
        mov     eax, [esp+__registry_value_length]

.restore_stack_and_return:
        add     esp, 4
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  SetLastError, eax
        mov     eax, -1
        jmp     .restore_stack_and_return
endp

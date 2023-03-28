; Pseudo C / compatible.asm
; -------------------------
; 08.05.2022 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CompatibleRegDeleteKeyExA

_hKey = 4
_lpSubKey = 8
_samDesired = 12
_Reserved = 16

        invoke  GetModuleHandle, .ADVAPI32.DLL
        test    eax, eax
        jz      @f
        invoke  GetProcAddress, eax, .RegDeleteKeyExA
        test    eax, eax
        jz      @f
        jmp     eax

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        invoke  RegDeleteKeyA, dword [esp+4+_hKey], dword [esp+_lpSubKey]
        retn    16

align PSEUDO_C_INSTRUCTIONS_ALIGN

.ADVAPI32.DLL db 'ADVAPI32.DLL', 0
align 4
.RegDeleteKeyExA db 'RegDeleteKeyExA', 0

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CompatibleRegDeleteKeyExW

_hKey = 4
_lpSubKey = 8
_samDesired = 12
_Reserved = 16

        invoke  GetModuleHandle, .ADVAPI32.DLL
        test    eax, eax
        jz      @f
        invoke  GetProcAddress, eax, .RegDeleteKeyExW
        test    eax, eax
        jz      @f
        jmp     eax

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        invoke  RegDeleteKeyW, dword [esp+4+_hKey], dword [esp+_lpSubKey]
        retn    16

align PSEUDO_C_INSTRUCTIONS_ALIGN

.ADVAPI32.DLL du 'ADVAPI32.DLL', 0
align 4
.RegDeleteKeyExW db 'RegDeleteKeyExW', 0

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CompatibleGetFileSizeEx

_hFile = 4
_lpFileSize = 8

        push    ebx
        mov     ebx, [esp+4+_lpFileSize]
        lea     eax, [ebx+LARGE_INTEGER.HighPart]
        invoke  GetFileSize, dword [esp+4+4+_hFile], eax
        cmp     eax, INVALID_FILE_SIZE
        jnz     @f
        invoke  GetLastError
        test    eax, eax
        jnz     .return_failure
        dec     eax
    @@: mov     [ebx+LARGE_INTEGER.LowPart], eax
        mov     eax, TRUE
    @@: pop     ebx
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_failure:
        xor     eax, eax
        jmp     @b
endp

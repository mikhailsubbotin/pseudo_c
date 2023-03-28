; Pseudo C / hardware.asm
; -----------------------
; 27.03.2020 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc IsDriveReadyA

_lpszDrive = 4

        push    ebx
        invoke  SetErrorMode, SEM_FAILCRITICALERRORS
        mov     ebx, eax
        mov     eax, [esp+4+_lpszDrive]
        sub     esp, 4 * 2 + MAX_PATH * 2
        lea     edx, [esp+4]
        lea     ecx, [edx+(4+MAX_PATH)]
        push    MAX_PATH
        push    ecx
        lea     ecx, [esp+8]
        push    edx
        lea     edx, [edx+4]
        push    ecx
        push    NULL
        push    MAX_PATH
        push    edx
        push    eax
        call    [GetVolumeInformationA]
        add     esp, 4 * 2 + MAX_PATH * 2
        push    ebx
        mov     ebx, eax
        call    [SetErrorMode]
        mov     eax, ebx
        pop     ebx
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc IsDriveReadyW

_lpszDrive = 4

        push    ebx
        invoke  SetErrorMode, SEM_FAILCRITICALERRORS
        mov     ebx, eax
        mov     eax, [esp+4+_lpszDrive]
        sub     esp, 4 * 2 + (MAX_PATH * 2) * 2
        lea     edx, [esp+4]
        lea     ecx, [edx+(4+MAX_PATH*2)]
        push    MAX_PATH
        push    ecx
        lea     ecx, [esp+8]
        push    edx
        lea     edx, [edx+4]
        push    ecx
        push    NULL
        push    MAX_PATH
        push    edx
        push    eax
        call    [GetVolumeInformationW]
        add     esp, 4 * 2 + (MAX_PATH * 2) * 2
        push    ebx
        mov     ebx, eax
        call    [SetErrorMode]
        mov     eax, ebx
        pop     ebx
        retn    4
endp

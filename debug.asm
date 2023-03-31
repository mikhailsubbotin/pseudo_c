; Pseudo C / debug.asm
; --------------------
; 31.03.2023 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc DebugBreakpointMessageA

_hWnd = 4
_szComment = 8

        pushfd
        pushad
        invoke  GetLastError
        mov     esi, [esp+36+_szComment]
        push    eax
        test    esi, esi
        jnz     @f
        mov     esi, .message_no
    @@: ccall   c_strlen, esi
        mov     ebx, eax
        add     eax, 732
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_memory_block
        mov     edi, eax
        mov     dword [eax], 'Comm'
        mov     dword [eax+4], 'ent:'
        mov     byte [eax+8], ' '
        push    ebx
        push    esi
        add     eax, 9
        push    eax
        add     ebx, eax
        call    c_memcpy
        add     esp, 12
        mov     dword [ebx], 0x0A0D0A0D ; 13, 10, 13, 10
        mov     dword [ebx+4], 'Stac'
        mov     dword [ebx+8], 0x0A0D shl 16 or 'k:'
        mov     dword [ebx+12], '    '
        mov     dword [ebx+16], 0x0D shl 24 or '...'
        mov     dword [ebx+20], '   ' shl 8 or 0x0A
        mov     dword [ebx+24], ' $+1'
        mov     dword [ebx+28], ('0' shl 24) or (9 shl 16) or '6:'
        mov     byte [ebx+32], 'x'
        add     ebx, 33
        ccall   xtoua, ebx, 8, dword [esp+4+36+_szComment+20] ; stack + 16
        add     ebx, 8
        mov     dword [ebx], '  ' shl 16 or 0x0A0D
        mov     dword [ebx+4], '  $+'
        mov     dword [ebx+8], 9 shl 24 or '12:'
        mov     word [ebx+12], '0x'
        add     ebx, 14
        ccall   xtoua, ebx, 8, dword [esp+4+36+_szComment+16] ; stack + 12
        add     ebx, 8
        mov     dword [ebx], '  ' shl 16 or 0x0A0D
        mov     dword [ebx+4], '  $+'
        mov     dword [ebx+8], ('0' shl 24) or (9 shl 16) or '8:'
        mov     byte [ebx+12], 'x'
        add     ebx, 13
        ccall   xtoua, ebx, 8, dword [esp+4+36+_szComment+12] ; stack + 8
        add     ebx, 8
        mov     dword [ebx], '  ' shl 16 or 0x0A0D
        mov     dword [ebx+4], '  $+'
        mov     dword [ebx+8], ('0' shl 24) or (9 shl 16) or '4:'
        mov     byte [ebx+12], 'x'
        add     ebx, 13
        ccall   xtoua, ebx, 8, dword [esp+4+36+_szComment+8] ; stack + 4
        add     ebx, 8
        mov     dword [ebx], '  ' shl 16 or 0x0A0D
        mov     dword [ebx+4], '  $:'
        mov     word [ebx+8], '0' shl 8 or 9
        mov     byte [ebx+10], 'x'
        add     ebx, 11
        ccall   xtoua, ebx, 8, dword [esp+4+36+_szComment+4] ; stack
        add     ebx, 8
        mov     dword [ebx], 0x0A0D0A0D ; 13, 10, 13, 10
        mov     dword [ebx+4], '    '
        mov     dword [ebx+8], 'EIP:'
        mov     word [ebx+12], '0' shl 8 or 9
        mov     byte [ebx+14], 'x'
        add     ebx, 15
        ccall   xtoua, ebx, 8, dword [esp+4+36] ; EIP
        add     ebx, 8
        mov     dword [ebx], 0x0A0D0A0D ; 13, 10, 13, 10
        mov     dword [ebx+4], 'Regi'
        mov     dword [ebx+8], 'ster'
        mov     dword [ebx+12], 0x0A0D shl 16 or 's:'
        mov     dword [ebx+16], '  ' shl 16 or 0x0A0D
        mov     dword [ebx+20], '  EA'
        mov     dword [ebx+24], ('0' shl 24) or (9 shl 16) or 'X:'
        mov     byte [ebx+28], 'x'
        add     ebx, 29
        ccall   xtoua, ebx, 8, dword [esp+4+28] ; EAX
        mov     word [ebx+8], '  '
        mov     byte [ebx+10], '('
        add     ebx, 8 + 3
        ccall   c_ultoa, dword [esp+8+4+28], ebx, 10 ; EAX
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     dword [ebx+4], '   E'
        mov     dword [ebx+8], 9 shl 24 or 'CX:'
        mov     word [ebx+12], '0x'
        add     ebx, 14
        ccall   xtoua, ebx, 8, dword [esp+4+24] ; ECX
        mov     word [ebx+8], '  '
        mov     byte [ebx+10], '('
        add     ebx, 8 + 3
        ccall   c_ultoa, dword [esp+8+4+24], ebx, 10 ; ECX
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     dword [ebx+4], '   E'
        mov     dword [ebx+8], 9 shl 24 or 'DX:'
        mov     word [ebx+12], '0x'
        add     ebx, 14
        ccall   xtoua, ebx, 8, dword [esp+4+20] ; EDX
        mov     word [ebx+8], '  '
        mov     byte [ebx+10], '('
        add     ebx, 8 + 3
        ccall   c_ultoa, dword [esp+8+4+20], ebx, 10 ; EDX
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     dword [ebx+4], '   E'
        mov     dword [ebx+8], 9 shl 24 or 'BX:'
        mov     word [ebx+12], '0x'
        add     ebx, 14
        ccall   xtoua, ebx, 8, dword [esp+4+16] ; EBX
        mov     word [ebx+8], '  '
        mov     byte [ebx+10], '('
        add     ebx, 8 + 3
        ccall   c_ultoa, dword [esp+8+4+16], ebx, 10 ; EBX
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     dword [ebx+4], '   E'
        mov     dword [ebx+8], 9 shl 24 or 'SP:'
        mov     word [ebx+12], '0x'
        add     ebx, 14
        lea     eax, [esp+4+36+_szComment+4] ; ESP
        ccall   xtoua, ebx, 8, eax
        mov     word [ebx+8], '  '
        mov     byte [ebx+10], '('
        add     ebx, 8 + 3
        lea     eax, [esp+4+36+_szComment+4] ; ESP
        ccall   c_ultoa, eax, ebx, 10
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     dword [ebx+4], '   E'
        mov     dword [ebx+8], 9 shl 24 or 'BP:'
        mov     word [ebx+12], '0x'
        add     ebx, 14
        ccall   xtoua, ebx, 8, dword [esp+4+8] ; EBP
        mov     word [ebx+8], '  '
        mov     byte [ebx+10], '('
        add     ebx, 8 + 3
        ccall   c_ultoa, dword [esp+8+4+8], ebx, 10 ; EBP
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     dword [ebx+4], '   E'
        mov     dword [ebx+8], 9 shl 24 or 'SI:'
        mov     word [ebx+12], '0x'
        add     ebx, 14
        ccall   xtoua, ebx, 8, dword [esp+4+4] ; ESI
        mov     word [ebx+8], '  '
        mov     byte [ebx+10], '('
        add     ebx, 8 + 3
        ccall   c_ultoa, dword [esp+8+4+4], ebx, 10 ; ESI
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     dword [ebx+4], '   E'
        mov     dword [ebx+8], 9 shl 24 or 'DI:'
        mov     word [ebx+12], '0x'
        add     ebx, 14
        ccall   xtoua, ebx, 8, dword [esp+4] ; EDI
        mov     word [ebx+8], '  '
        mov     byte [ebx+10], '('
        add     ebx, 8 + 3
        ccall   c_ultoa, dword [esp+8+4], ebx, 10 ; EDI
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x0D0A0D shl 8 or ')'
        mov     dword [ebx+4], 'Fla' shl 8 or 0x0A
        mov     dword [ebx+8], 0x0D shl 24 or 'gs:'
        mov     dword [ebx+12], ' ' shl 24 or 0x0A0D0A
        mov     word [ebx+16], '  '
        mov     byte [ebx+18], ' '
        add     ebx, 19
        mov     si, [esp+4+32] ; flags
        bt      si, 0 ; CF
        setc    al
        or      al, 0x30
        mov     [ebx], al
        mov     dword [ebx+1], ' - C'
        mov     dword [ebx+5], 'F (C'
        mov     dword [ebx+9], 'arry'
        mov     dword [ebx+13], ' Fla'
        mov     dword [ebx+17], 0x0A0D shl 16 or 'g)'
        mov     dword [ebx+21], '    '
        add     ebx, 25
        bt      si, 2 ; PF
        setc    al
        or      al, 0x30
        mov     [ebx], al
        mov     dword [ebx+1], ' - P'
        mov     dword [ebx+5], 'F (P'
        mov     dword [ebx+9], 'arit'
        mov     dword [ebx+13], 'y Fl'
        mov     dword [ebx+17], 0x0D shl 24 or 'ag)'
        mov     dword [ebx+21], '   ' shl 8 or 0x0A
        mov     byte [ebx+25], ' '
        add     ebx, 26
        bt      si, 4 ; AF
        setc    al
        or      al, 0x30
        mov     [ebx], al
        mov     dword [ebx+1], ' - A'
        mov     dword [ebx+5], 'F (A'
        mov     dword [ebx+9], 'uxil'
        mov     dword [ebx+13], 'iary'
        mov     dword [ebx+17], ' Car'
        mov     dword [ebx+21], 'ry F'
        mov     dword [ebx+25], 'lag)'
        mov     dword [ebx+29], '  ' shl 16 or 0x0A0D
        mov     word [ebx+33], '  '
        add     ebx, 35
        bt      si, 6 ; ZF
        setc    al
        or      al, 0x30
        mov     [ebx], al
        mov     dword [ebx+1], ' - Z'
        mov     dword [ebx+5], 'F (Z'
        mov     dword [ebx+9], 'ero '
        mov     dword [ebx+13], 'Flag'
        mov     dword [ebx+17], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     word [ebx+21], '  '
        mov     byte [ebx+23], ' '
        add     ebx, 24
        bt      si, 7 ; SF
        setc    al
        or      al, 0x30
        mov     [ebx], al
        mov     dword [ebx+1], ' - S'
        mov     dword [ebx+5], 'F (S'
        mov     dword [ebx+9], 'ign '
        mov     dword [ebx+13], 'Flag'
        mov     dword [ebx+17], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     word [ebx+21], '  '
        mov     byte [ebx+23], ' '
        add     ebx, 24
        bt      si, 8 ; TF
        setc    al
        or      al, 0x30
        mov     [ebx], al
        mov     dword [ebx+1], ' - T'
        mov     dword [ebx+5], 'F (T'
        mov     dword [ebx+9], 'rap '
        mov     dword [ebx+13], 'Flag'
        mov     dword [ebx+17], (' ' shl 24) or (0x0A0D shl 8) or ')'
        mov     word [ebx+21], '  '
        mov     byte [ebx+23], ' '
        add     ebx, 24
        bt      si, 10 ; DF
        setc    al
        or      al, 0x30
        mov     [ebx], al
        mov     dword [ebx+1], ' - D'
        mov     dword [ebx+5], 'F (D'
        mov     dword [ebx+9], 'irec'
        mov     dword [ebx+13], 'tion'
        mov     dword [ebx+17], ' Fla'
        mov     dword [ebx+21], 0x0A0D shl 16 or 'g)'
        mov     dword [ebx+25], '    '
        add     ebx, 29
        bt      si, 11 ; OF
        setc    al
        or      al, 0x30
        mov     [ebx], al
        mov     dword [ebx+1], ' - O'
        mov     dword [ebx+5], 'F (O'
        mov     dword [ebx+9], 'verf'
        mov     dword [ebx+13], 'low '
        mov     dword [ebx+17], 'Flag'
        mov     dword [ebx+21], 0x0D0A0D shl 8 or ')'
        mov     dword [ebx+25], 'Get' shl 8 or 0x0A
        mov     dword [ebx+29], 'Last'
        mov     dword [ebx+33], 'Erro'
        mov     word [ebx+37], 'r:'
        mov     byte [ebx+39], ' '
        add     ebx, 40
        ccall   c_ultoa, dword [esp+8], ebx, 10 ; GetLastError
    @@: inc     ebx
        cmp     byte [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x0A0D0A0D ; 13, 10, 13, 10
        mov     dword [ebx+4], 'Cont'
        mov     dword [ebx+8], 'inue'
        mov     dword [ebx+12], ' exe'
        mov     dword [ebx+16], 'cuti'
        mov     dword [ebx+20], 0 shl 24 or 'on?'
        mov     eax, [esp+4+36+_hWnd]
        cmp     eax, -1
        jnz     @f
        invoke  GetActiveWindow
    @@: invoke  MessageBoxA, eax, edi, .caption, MB_YESNO
        mov     ebx, eax
        stdcall ProcessHeapFree, edi
        cmp     ebx, IDYES
        jz      .restore_registers_and_flags
        invoke  ExitProcess, NULL
        int3

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.restore_registers_and_flags:
        add     esp, 4
        popad
        popfd
        retn    8

align PSEUDO_C_INSTRUCTIONS_ALIGN

.message_no db 'No', 0
align 4
.caption db 'Breakpoint', 0

align PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_memory_block:
        invoke  GetLastError
        stdcall SystemErrorMessageA, dword [esp+4+4+36+_hWnd], eax
        jmp     .restore_registers_and_flags
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc DebugBreakpointMessageW

_hWnd = 4
_wcsComment = 8

        pushfd
        pushad
        invoke  GetLastError
        mov     esi, [esp+36+_wcsComment]
        push    eax
        test    esi, esi
        jnz     @f
        mov     esi, .message_no
    @@: ccall   c_wcslen, esi
        shl     eax, 1
        mov     ebx, eax
        add     eax, 732 * 2
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_memory_block
        mov     edi, eax
        mov     dword [eax], 0x006F0043 ; 'Co'
        mov     dword [eax+4], 0x006D006D ; 'mm'
        mov     dword [eax+8], 0x006E0065 ; 'en'
        mov     dword [eax+12], 0x003A0074 ; 't:'
        mov     word [eax+16], 0x0020 ; ' '
        push    ebx
        push    esi
        add     eax, 18
        push    eax
        add     ebx, eax
        call    c_memcpy
        add     esp, 12
        mov     dword [ebx], 0x000A000D ; 13, 10
        mov     dword [ebx+4], 0x000A000D ; 13, 10
        mov     dword [ebx+8], 0x00740053 ; 'St'
        mov     dword [ebx+12], 0x00630061 ; 'ac'
        mov     dword [ebx+16], 0x003A006B ; 'k:'
        mov     dword [ebx+20], 0x000A000D ; 13, 10
        add     ebx, 24
        mov     dword [ebx], 0x00200020 ; '  '
        mov     dword [ebx+4], 0x00200020 ; '  '
        mov     dword [ebx+8], 0x002E002E ; '..'
        mov     dword [ebx+12], 0x000D002E ; '.', 13
        mov     dword [ebx+16], 0x0020000A ; 10, ' '
        mov     dword [ebx+20], 0x00200020 ; '  '
        mov     dword [ebx+24], 0x00240020 ; ' $'
        mov     dword [ebx+28], 0x0031002B ; '+1'
        mov     dword [ebx+32], 0x003A0036 ; '6:'
        mov     dword [ebx+36], 0x00300009 ; 9, '0'
        mov     word [ebx+40], 0x0078 ; 'x'
        add     ebx, 42
        ccall   xtouw, ebx, 8, dword [esp+4+36+_wcsComment+20] ; stack + 16
        add     ebx, 8 * 2
        mov     dword [ebx], 0x000A000D ; 13, 10
        mov     dword [ebx+4], 0x00200020 ; '  '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x002B0024 ; '$+'
        mov     dword [ebx+16], 0x00320031 ; '12'
        mov     dword [ebx+20], 0x0009003A ; ':', 9
        mov     dword [ebx+24], 0x00780030 ; '0x'
        add     ebx, 28
        ccall   xtouw, ebx, 8, dword [esp+4+36+_wcsComment+16] ; stack + 12
        add     ebx, 8 * 2
        mov     dword [ebx], 0x000A000D ; 13, 10
        mov     dword [ebx+4], 0x00200020 ; '  '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x002B0024 ; '$+'
        mov     dword [ebx+16], 0x003A0038 ; '8:'
        mov     dword [ebx+20], 0x00300009 ; 9, '0'
        mov     word [ebx+24], 0x0078 ; 'x'
        add     ebx, 26
        ccall   xtouw, ebx, 8, dword [esp+4+36+_wcsComment+12] ; stack + 8
        add     ebx, 8 * 2
        mov     dword [ebx], 0x000A000D ; 13, 10
        mov     dword [ebx+4], 0x00200020 ; '  '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x002B0024 ; '$+'
        mov     dword [ebx+16], 0x003A0034 ; '4:'
        mov     dword [ebx+20], 0x00300009 ; 9, '0'
        mov     word [ebx+24], 0x0078 ; 'x'
        add     ebx, 26
        ccall   xtouw, ebx, 8, dword [esp+4+36+_wcsComment+8] ; stack + 4
        add     ebx, 8 * 2
        mov     dword [ebx], 0x000A000D ; 13, 10
        mov     dword [ebx+4], 0x00200020 ; '  '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x003A0024 ; '$:'
        mov     dword [ebx+16], 0x00300009 ; 9, '0'
        mov     word [ebx+20], 0x0078 ; 'x'
        add     ebx, 22
        ccall   xtouw, ebx, 8, dword [esp+4+36+_wcsComment+4] ; stack
        add     ebx, 8 * 2
        mov     dword [ebx], 0x000A000D ; 13, 10
        mov     dword [ebx+4], 0x000A000D ; 13, 10
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x00200020 ; '  '
        mov     dword [ebx+16], 0x00490045 ; 'EI'
        mov     dword [ebx+20], 0x003A0050 ; 'P:'
        mov     dword [ebx+24], 0x00300009 ; 9, '0'
        mov     word [ebx+28], 0x0078 ; 'x'
        add     ebx, 30
        ccall   xtouw, ebx, 8, dword [esp+4+36] ; EIP
        add     ebx, 8 * 2
        mov     dword [ebx], 0x000A000D ; 13, 10
        mov     dword [ebx+4], 0x000A000D ; 13, 10
        mov     dword [ebx+8], 0x00650052 ; 'Re'
        mov     dword [ebx+12], 0x00690067 ; 'gi'
        mov     dword [ebx+16], 0x00740073 ; 'st'
        mov     dword [ebx+20], 0x00720065 ; 'er'
        mov     dword [ebx+24], 0x003A0073 ; 's:'
        mov     dword [ebx+28], 0x000A000D ; 13, 10
        mov     dword [ebx+32], 0x000A000D ; 13, 10
        mov     dword [ebx+36], 0x00200020 ; '  '
        mov     dword [ebx+40], 0x00200020 ; '  '
        mov     dword [ebx+44], 0x00410045 ; 'EA'
        mov     dword [ebx+48], 0x003A0058 ; 'X:'
        mov     dword [ebx+52], 0x00300009 ; 9, '0'
        mov     word [ebx+56], 0x0078 ; 'x'
        add     ebx, 58
        ccall   xtouw, ebx, 8, dword [esp+4+28] ; EAX
        mov     dword [ebx+(8*2)], 0x00200020 ; '  '
        mov     word [ebx+((8*2)+4)], 0x0028 ; '('
        add     ebx, 8 * 2 + 6
        ccall   c_ultow, dword [esp+8+4+28], ebx, 10 ; EAX
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000D0029 ; ')', 13
        mov     dword [ebx+4], 0x0020000A ; 10, ' '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x00450020 ; ' E'
        mov     dword [ebx+16], 0x00580043 ; 'CX'
        mov     dword [ebx+20], 0x0009003A ; ':', 9
        mov     dword [ebx+24], 0x00780030 ; '0x'
        add     ebx, 28
        ccall   xtouw, ebx, 8, dword [esp+4+24] ; ECX
        mov     dword [ebx+(8*2)], 0x00200020 ; '  '
        mov     word [ebx+((8*2)+4)], 0x0028 ; '('
        add     ebx, 8 * 2 + 6
        ccall   c_ultow, dword [esp+8+4+24], ebx, 10 ; ECX
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000D0029 ; ')', 13
        mov     dword [ebx+4], 0x0020000A ; 10, ' '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x00450020 ; ' E'
        mov     dword [ebx+16], 0x00580044 ; 'DX'
        mov     dword [ebx+20], 0x0009003A ; ':', 9
        mov     dword [ebx+24], 0x00780030 ; '0x'
        add     ebx, 28
        ccall   xtouw, ebx, 8, dword [esp+4+20] ; EDX
        mov     dword [ebx+(8*2)], 0x00200020 ; '  '
        mov     word [ebx+((8*2)+4)], 0x0028 ; '('
        add     ebx, 8 * 2 + 6
        ccall   c_ultow, dword [esp+8+4+20], ebx, 10 ; EDX
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000D0029 ; ')', 13
        mov     dword [ebx+4], 0x0020000A ; 10, ' '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x00450020 ; ' E'
        mov     dword [ebx+16], 0x00580042 ; 'BX'
        mov     dword [ebx+20], 0x0009003A ; ':', 9
        mov     dword [ebx+24], 0x00780030 ; '0x'
        add     ebx, 28
        ccall   xtouw, ebx, 8, dword [esp+4+16] ; EBX
        mov     dword [ebx+(8*2)], 0x00200020 ; '  '
        mov     word [ebx+((8*2)+4)], 0x0028 ; '('
        add     ebx, 8 * 2 + 6
        ccall   c_ultow, dword [esp+8+4+16], ebx, 10 ; EBX
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000D0029 ; ')', 13
        mov     dword [ebx+4], 0x0020000A ; 10, ' '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x00450020 ; ' E'
        mov     dword [ebx+16], 0x00500053 ; 'SP'
        mov     dword [ebx+20], 0x0009003A ; ':', 9
        mov     dword [ebx+24], 0x00780030 ; '0x'
        add     ebx, 28
        lea     eax, [esp+4+36+_wcsComment+4] ; ESP
        ccall   xtouw, ebx, 8, eax ; EBX
        mov     dword [ebx+(8*2)], 0x00200020 ; '  '
        mov     word [ebx+((8*2)+4)], 0x0028 ; '('
        add     ebx, 8 * 2 + 6
        lea     eax, [esp+4+36+_wcsComment+4] ; ESP
        ccall   c_ultow, eax, ebx, 10
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000D0029 ; ')', 13
        mov     dword [ebx+4], 0x0020000A ; 10, ' '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x00450020 ; ' E'
        mov     dword [ebx+16], 0x00500042 ; 'BP'
        mov     dword [ebx+20], 0x0009003A ; ':', 9
        mov     dword [ebx+24], 0x00780030 ; '0x'
        add     ebx, 28
        ccall   xtouw, ebx, 8, dword [esp+4+8] ; EBP
        mov     dword [ebx+(8*2)], 0x00200020 ; '  '
        mov     word [ebx+((8*2)+4)], 0x0028 ; '('
        add     ebx, 8 * 2 + 6
        ccall   c_ultow, dword [esp+8+4+8], ebx, 10 ; EBP
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000D0029 ; ')', 13
        mov     dword [ebx+4], 0x0020000A ; 10, ' '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x00450020 ; ' E'
        mov     dword [ebx+16], 0x00490053 ; 'SI'
        mov     dword [ebx+20], 0x0009003A ; ':', 9
        mov     dword [ebx+24], 0x00780030 ; '0x'
        add     ebx, 28
        ccall   xtouw, ebx, 8, dword [esp+4+4] ; ESI
        mov     dword [ebx+(8*2)], 0x00200020 ; '  '
        mov     word [ebx+((8*2)+4)], 0x0028 ; '('
        add     ebx, 8 * 2 + 6
        ccall   c_ultow, dword [esp+8+4+4], ebx, 10 ; ESI
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000D0029 ; ')', 13
        mov     dword [ebx+4], 0x0020000A ; 10, ' '
        mov     dword [ebx+8], 0x00200020 ; '  '
        mov     dword [ebx+12], 0x00450020 ; ' E'
        mov     dword [ebx+16], 0x00490044 ; 'DI'
        mov     dword [ebx+20], 0x0009003A ; ':', 9
        mov     dword [ebx+24], 0x00780030 ; '0x'
        add     ebx, 28
        ccall   xtouw, ebx, 8, dword [esp+4] ; EDI
        mov     dword [ebx+(8*2)], 0x00200020 ; '  '
        mov     word [ebx+((8*2)+4)], 0x0028 ; '('
        add     ebx, 8 * 2 + 6
        ccall   c_ultow, dword [esp+8+4], ebx, 10 ; EDI
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000D0029 ; ')', 13
        mov     dword [ebx+4], 0x000D000A ; 10, 13
        mov     dword [ebx+8], 0x0046000A ; 10, 'F'
        mov     dword [ebx+12], 0x0061006C ; 'la'
        mov     dword [ebx+16], 0x00730067 ; 'gs'
        mov     dword [ebx+20], 0x000D003A ; ':', 13
        mov     dword [ebx+24], 0x000D000A ; 10, 13
        mov     dword [ebx+28], 0x0020000A ; 10, ' '
        mov     dword [ebx+32], 0x00200020 ; '  '
        mov     word [ebx+36], 0x0020 ; ' '
        add     ebx, 38
        xor     ax, ax
        mov     si, [esp+4+32] ; flags
        bt      si, 0 ; CF
        setc    al
        or      al, 0x30
        mov     [ebx], ax
        mov     dword [ebx+2], 0x002D0020 ; ' -'
        mov     dword [ebx+6], 0x00430020 ; ' C'
        mov     dword [ebx+10], 0x00200046 ; 'F '
        mov     dword [ebx+14], 0x00430028 ; '(C'
        mov     dword [ebx+18], 0x00720061 ; 'ar'
        mov     dword [ebx+22], 0x00790072 ; 'ry'
        mov     dword [ebx+26], 0x00460020 ; ' F'
        mov     dword [ebx+30], 0x0061006C ; 'la'
        mov     dword [ebx+34], 0x00290067 ; 'g)'
        mov     dword [ebx+38], 0x000A000D ; 13, 10
        mov     dword [ebx+42], 0x00200020 ; '  '
        mov     dword [ebx+46], 0x00200020 ; '  '
        add     ebx, 50
        bt      si, 2 ; PF
        setc    al
        or      al, 0x30
        mov     [ebx], ax
        mov     dword [ebx+2], 0x002D0020 ; ' -'
        mov     dword [ebx+6], 0x00500020 ; ' P'
        mov     dword [ebx+10], 0x00200046 ; 'F '
        mov     dword [ebx+14], 0x00500028 ; '(P'
        mov     dword [ebx+18], 0x00720061 ; 'ar'
        mov     dword [ebx+22], 0x00740069 ; 'it'
        mov     dword [ebx+26], 0x00200079 ; 'y '
        mov     dword [ebx+30], 0x006C0046 ; 'Fl'
        mov     dword [ebx+34], 0x00670061 ; 'ag'
        mov     dword [ebx+38], 0x000D0029 ; ')', 13
        mov     dword [ebx+42], 0x0020000A ; 10, ' '
        mov     dword [ebx+46], 0x00200020 ; '  '
        mov     word [ebx+50], 0x0020 ; ' '
        add     ebx, 52
        bt      si, 4 ; AF
        setc    al
        or      al, 0x30
        mov     [ebx], ax
        mov     dword [ebx+2], 0x002D0020 ; ' -'
        mov     dword [ebx+6], 0x00410020 ; ' A'
        mov     dword [ebx+10], 0x00200046 ; 'F '
        mov     dword [ebx+14], 0x00410028 ; '(A'
        mov     dword [ebx+18], 0x00780075 ; 'ux'
        mov     dword [ebx+22], 0x006C0069 ; 'il'
        mov     dword [ebx+26], 0x00610069 ; 'ia'
        mov     dword [ebx+30], 0x00790072 ; 'ry'
        mov     dword [ebx+34], 0x00430020 ; ' C'
        mov     dword [ebx+38], 0x00720061 ; 'ar'
        mov     dword [ebx+42], 0x00790072 ; 'ry'
        mov     dword [ebx+46], 0x00460020 ; ' F'
        mov     dword [ebx+50], 0x0061006C ; 'la'
        mov     dword [ebx+54], 0x00290067 ; 'g)'
        mov     dword [ebx+58], 0x000A000D ; 13, 10
        mov     dword [ebx+62], 0x00200020 ; '  '
        mov     dword [ebx+66], 0x00200020 ; '  '
        add     ebx, 70
        bt      si, 6 ; ZF
        setc    al
        or      al, 0x30
        mov     [ebx], ax
        mov     dword [ebx+2], 0x002D0020 ; ' -'
        mov     dword [ebx+6], 0x005A0020 ; ' Z'
        mov     dword [ebx+10], 0x00200046 ; 'F '
        mov     dword [ebx+14], 0x005A0028 ; '(Z'
        mov     dword [ebx+18], 0x00720065 ; 'er'
        mov     dword [ebx+22], 0x0020006F ; 'o '
        mov     dword [ebx+26], 0x006C0046 ; 'Fl'
        mov     dword [ebx+30], 0x00670061 ; 'ag'
        mov     dword [ebx+34], 0x000D0029 ; ')', 13
        mov     dword [ebx+38], 0x0020000A ; 10, ' '
        mov     dword [ebx+42], 0x00200020 ; '  '
        mov     word [ebx+46], 0x0020 ; ' '
        add     ebx, 48
        bt      si, 7 ; SF
        setc    al
        or      al, 0x30
        mov     [ebx], ax
        mov     dword [ebx+2], 0x002D0020 ; ' -'
        mov     dword [ebx+6], 0x00530020 ; ' S'
        mov     dword [ebx+10], 0x00200046 ; 'F '
        mov     dword [ebx+14], 0x00530028 ; '(S'
        mov     dword [ebx+18], 0x00670069 ; 'ig'
        mov     dword [ebx+22], 0x0020006E ; 'n '
        mov     dword [ebx+26], 0x006C0046 ; 'Fl'
        mov     dword [ebx+30], 0x00670061 ; 'ag'
        mov     dword [ebx+34], 0x000D0029 ; ')', 13
        mov     dword [ebx+38], 0x0020000A ; 10, ' '
        mov     dword [ebx+42], 0x00200020 ; '  '
        mov     word [ebx+46], 0x0020 ; ' '
        add     ebx, 48
        bt      si, 8 ; TF
        setc    al
        or      al, 0x30
        mov     [ebx], ax
        mov     dword [ebx+2], 0x002D0020 ; ' -'
        mov     dword [ebx+6], 0x00540020 ; ' T'
        mov     dword [ebx+10], 0x00200046 ; 'F '
        mov     dword [ebx+14], 0x00540028 ; '(T'
        mov     dword [ebx+18], 0x00610072 ; 'ra'
        mov     dword [ebx+22], 0x00200070 ; 'p '
        mov     dword [ebx+26], 0x006C0046 ; 'Fl'
        mov     dword [ebx+30], 0x00670061 ; 'ag'
        mov     dword [ebx+34], 0x000D0029 ; ')', 13
        mov     dword [ebx+38], 0x0020000A ; 10, ' '
        mov     dword [ebx+42], 0x00200020 ; '  '
        mov     word [ebx+46], 0x0020 ; ' '
        add     ebx, 48
        bt      si, 10 ; DF
        setc    al
        or      al, 0x30
        mov     [ebx], ax
        mov     dword [ebx+2], 0x002D0020 ; ' -'
        mov     dword [ebx+6], 0x00440020 ; ' D'
        mov     dword [ebx+10], 0x00200046 ; 'F '
        mov     dword [ebx+14], 0x00440028 ; '(D'
        mov     dword [ebx+18], 0x00720069 ; 'ir'
        mov     dword [ebx+22], 0x00630065 ; 'ec'
        mov     dword [ebx+26], 0x00690074 ; 'ti'
        mov     dword [ebx+30], 0x006E006F ; 'on'
        mov     dword [ebx+34], 0x00460020 ; ' F'
        mov     dword [ebx+38], 0x0061006C ; 'la'
        mov     dword [ebx+42], 0x00290067 ; 'g)'
        mov     dword [ebx+46], 0x000A000D ; 13, 10
        mov     dword [ebx+50], 0x00200020 ; '  '
        mov     dword [ebx+54], 0x00200020 ; '  '
        add     ebx, 58
        bt      si, 11 ; OF
        setc    al
        or      al, 0x30
        mov     [ebx], ax
        mov     dword [ebx+2], 0x002D0020 ; ' -'
        mov     dword [ebx+6], 0x004F0020 ; ' O'
        mov     dword [ebx+10], 0x00200046 ; 'F '
        mov     dword [ebx+14], 0x004F0028 ; '(O'
        mov     dword [ebx+18], 0x00650076 ; 've'
        mov     dword [ebx+22], 0x00660072 ; 'rf'
        mov     dword [ebx+26], 0x006F006C ; 'lo'
        mov     dword [ebx+30], 0x00200077 ; 'w '
        mov     dword [ebx+34], 0x006C0046 ; 'Fl'
        mov     dword [ebx+38], 0x00670061 ; 'ag'
        mov     dword [ebx+42], 0x000D0029 ; ')', 13
        mov     dword [ebx+46], 0x000D000A ; 10, 13
        mov     dword [ebx+50], 0x0047000A ; 10, 'G'
        mov     dword [ebx+54], 0x00740065 ; 'et'
        mov     dword [ebx+58], 0x0061004C ; 'La'
        mov     dword [ebx+62], 0x00740073 ; 'st'
        mov     dword [ebx+66], 0x00720045 ; 'Er'
        mov     dword [ebx+70], 0x006F0072 ; 'ro'
        mov     dword [ebx+74], 0x003A0072 ; 'r:'
        mov     word [ebx+78], 0x0020 ; ' '
        add     ebx, 80
        ccall   c_ultow, dword [esp+8], ebx, 10 ; GetLastError
    @@: add     ebx, 2
        cmp     word [ebx], 0
        jnz     @b
        mov     dword [ebx], 0x000A000D ; 13, 10
        mov     dword [ebx+4], 0x000A000D ; 13, 10
        mov     dword [ebx+8], 0x006F0043 ; 'Co'
        mov     dword [ebx+12], 0x0074006E ; 'nt'
        mov     dword [ebx+16], 0x006E0069 ; 'in'
        mov     dword [ebx+20], 0x00650075 ; 'ue'
        mov     dword [ebx+24], 0x00650020 ; ' e'
        mov     dword [ebx+28], 0x00650078 ; 'xe'
        mov     dword [ebx+32], 0x00750063 ; 'cu'
        mov     dword [ebx+36], 0x00690074 ; 'ti'
        mov     dword [ebx+40], 0x006E006F ; 'on'
        mov     dword [ebx+44], 0x0000003F ; '?', 0
        mov     eax, [esp+4+36+_hWnd]
        cmp     eax, -1
        jnz     @f
        invoke  GetActiveWindow
    @@: invoke  MessageBoxW, eax, edi, .caption, MB_YESNO
        mov     ebx, eax
        stdcall ProcessHeapFree, edi
        cmp     ebx, IDYES
        jz      .restore_registers_and_flags
        invoke  ExitProcess, NULL
        int3

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.restore_registers_and_flags:
        add     esp, 4
        popad
        popfd
        retn    8

align PSEUDO_C_INSTRUCTIONS_ALIGN

.message_no du 'No', 0
align 4
.caption du 'Breakpoint', 0

align PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_memory_block:
        invoke  GetLastError
        stdcall SystemErrorMessageW, dword [esp+4+4+36+_hWnd], eax
        jmp     .restore_registers_and_flags
endp

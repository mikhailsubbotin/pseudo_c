; Pseudo C / pseudo_c.asm
; -----------------------
; 31.03.2023 © Mikhail Subbotin

include 'compatible.asm'
include 'debug.asm'
include 'errno.asm'
include 'fs.asm'
include 'gui.asm'
include 'hardware.asm'
include 'heap.asm'
include 'math.asm'
include 'memory.asm'
include 'path.asm'
include 'processor.asm'
include 'reflect.asm'
include 'stdout.asm'
include 'string.asm'
include 'system.asm'
include 'registry.asm'
include 'xtox.asm'

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_beep

_frq = 4
_dur = 8

        invoke  Beep, dword [esp+4+_frq], dword [esp+_dur]
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_sleep

_msc = 4

        mov     eax, [esp+_msc]
        test    eax, eax
        jnz     @f
        inc     eax
    @@: invoke  Sleep, eax
        retn
endp

; -----

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc aligned_uint_4

_uint = 4

        mov     eax, [esp+_uint]
        test    eax, 11b
        jz      @f
        and     eax, 11111111111111111111111111111100b
        add     eax, 100b
    @@:
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc aligned_uint_8

_uint = 4

        mov     eax, [esp+_uint]
        test    eax, 111b
        jz      @f
        and     eax, 11111111111111111111111111111000b
        add     eax, 1000b
    @@:
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc aligned_uint_16

_uint = 4

        mov     eax, [esp+_uint]
        test    eax, 1111b
        jz      @f
        and     eax, 11111111111111111111111111110000b
        add     eax, 10000b
    @@:
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc cmdarget

_argv = 4
_argc = 8
_argn = 12

        mov     eax, [esp+_argn]
        cmp     eax, 1
        jb      .return_zero
        cmp     [esp+_argc], eax
        jb      .return_zero
        dec     eax
        shl     eax, 2
        add     eax, [esp+_argv]
        mov     eax, [eax]
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_zero:
        xor     eax, eax
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc cmdargsearch

_argv = 4
_argc = 8
_str = 12

        push    ebx esi
        mov     esi, [esp+8+_argv]
        xor     ebx, ebx
    @@: ccall   c_strcmp, dword [esi+ebx*4], dword [esp+8+_str]
        inc     ebx
        test    eax, eax
        jz      .return_arg_num
        cmp     [esp+8+_argc], ebx
        jnz     @b
        xor     eax, eax
        pop     esi ebx
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_arg_num:
        mov     eax, ebx
        pop     esi ebx
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc wcmdargsearch

_argv = 4
_argc = 8
_str = 12

        push    ebx esi
        mov     esi, [esp+8+_argv]
        xor     ebx, ebx
    @@: ccall   c_wcscmp, dword [esi+ebx*4], dword [esp+8+_str]
        inc     ebx
        test    eax, eax
        jz      .return_arg_num
        cmp     [esp+8+_argc], ebx
        jnz     @b
        xor     eax, eax
        pop     esi ebx
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_arg_num:
        mov     eax, ebx
        pop     esi ebx
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc RGBColor

_red = 4
_green = 8
_blue = 12

        xor     eax, eax
        mov     ah, [esp+_blue]
        shl     eax, 8
        mov     ah, [esp+_green]
        mov     al, [esp+_red]
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetCurrentModuleHandle
        mov     edx, [esp]
        push    edi
        mov     ecx, sizeof.MEMORY_BASIC_INFORMATION
        sub     esp, ecx
        mov     edi, esp
        push    ecx ; for VirtualQuery [3]
        mov     ecx, sizeof.MEMORY_BASIC_INFORMATION / 4
        push    edi ; for VirtualQuery [2]
        xor     eax, eax
        rep     stosd
        push    edx ; for VirtualQuery [1]
        call    [VirtualQuery]
        test    eax, eax
        jz      @f
        mov     eax, [esp+MEMORY_BASIC_INFORMATION.AllocationBase]
    @@: add     esp, sizeof.MEMORY_BASIC_INFORMATION
        pop     edi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc SystemErrorMessageA

_hWnd = 4
_errCode = 8

__string_buffer = 0

        xor     eax, eax
        push    eax
        mov     edx, esp ; __string_buffer
        invoke  FormatMessageA, FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM, eax, dword [esp+16+4+_errCode], eax, edx, eax, eax
        test    eax, eax
        jz      @f
        invoke  MessageBoxA, dword [esp+12+4+_hWnd], dword [esp+8+__string_buffer], NULL, MB_ICONERROR or MB_OK
        call    [LocalFree]
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        sub     esp, 32 - 4
        mov     eax, esp
        mov     dword [esp], 'Syst'
        mov     dword [eax+4], 'em e'
        mov     dword [esp+8], 'rror'
        mov     dword [eax+12], '! Co'
        mov     dword [esp+16], 'de: '
        mov     word [eax+20], '0x'
        add     eax, 22
        stdcall xtoua, eax, 8, dword [esp+32+_errCode]
        lea     eax, [esp+12]
        invoke  MessageBoxA, dword [esp+12+12+32+_hWnd], eax, NULL, MB_ICONERROR or MB_OK
        add     esp, 12 + 32
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc SystemErrorMessageW

_hWnd = 4
_errCode = 8

__string_buffer = 0

        xor     eax, eax
        push    eax
        mov     edx, esp ; __string_buffer
        invoke  FormatMessageW, FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM, eax, dword [esp+16+4+_errCode], eax, edx, eax, eax
        test    eax, eax
        jz      @f
        invoke  MessageBoxW, dword [esp+12+4+_hWnd], dword [esp+8+__string_buffer], NULL, MB_ICONERROR or MB_OK
        call    [LocalFree]
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        sub     esp, (32 * 2) - 4
        mov     eax, esp
        mov     dword [esp], 'S' or ('y' shl 16)
        mov     dword [eax+4], 's' or ('t' shl 16)
        mov     dword [esp+8], 'e' or ('m' shl 16)
        mov     dword [eax+12], ' ' or ('e' shl 16)
        mov     dword [esp+16], 'r' or ('r' shl 16)
        mov     dword [eax+20], 'o' or ('r' shl 16)
        mov     dword [esp+24], '!' or (' ' shl 16)
        mov     dword [eax+28], 'C' or ('o' shl 16)
        mov     dword [esp+32], 'd' or ('e' shl 16)
        mov     dword [eax+36], ':' or (' ' shl 16)
        mov     dword [esp+40], '0' or ('x' shl 16)
        add     eax, 44
        stdcall xtouw, eax, 8, dword [esp+(32*2)+_errCode]
        lea     eax, [esp+12]
        invoke  MessageBoxW, dword [esp+12+12+(32*2)+_hWnd], eax, NULL, MB_ICONERROR or MB_OK
        add     esp, 12 + (32 * 2)
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc WritePrivateProfileIntA

_lpAppName = 4
_lpKeyName = 8
_lpValue = 12
_lpFileName = 16

__stack_length = 10 + 1 + 1

        sub     esp, __stack_length
        mov     eax, esp
        ccall   c_itoa, dword [esp+8+__stack_length+_lpValue], eax, 10
        mov     eax, esp
        invoke  WritePrivateProfileStringA, dword [esp+12+__stack_length+_lpAppName], dword [esp+8+__stack_length+_lpKeyName], eax, dword [esp+__stack_length+_lpFileName]
        add     esp, __stack_length
        retn    16
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc WritePrivateProfileIntW

_lpAppName = 4
_lpKeyName = 8
_lpValue = 12
_lpFileName = 16

__stack_length = (10 + 1) * 2 + 2

        sub     esp, __stack_length
        mov     eax, esp
        ccall   c_itow, dword [esp+8+__stack_length+_lpValue], eax, 10
        mov     eax, esp
        invoke  WritePrivateProfileStringW, dword [esp+12+__stack_length+_lpAppName], dword [esp+8+__stack_length+_lpKeyName], eax, dword [esp+__stack_length+_lpFileName]
        add     esp, __stack_length
        retn    16
endp

include 'entry.asm'

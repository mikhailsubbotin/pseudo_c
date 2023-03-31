; Pseudo C / stdout.asm
; ---------------------
; 31.03.2023 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc PrepareStdOutW
        push    esi
        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .return_error
        mov     esi, eax
        push    eax
        invoke  GetConsoleMode, eax, esp
        test    eax, eax
        jz      .write_file_bom
        add     esp, 4
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.restore_stack_and_return_error:
        add     esp, 4

.return_error:
        xor     eax, eax
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_file_bom:
        xor     ecx, ecx
        mov     eax, esp
        mov     [eax], ecx
        invoke  SetFilePointer, esi, ecx, eax, FILE_CURRENT
        cmp     eax, INVALID_SET_FILE_POINTER
        jz      .restore_stack_and_return_error
        test    eax, eax
        jnz     .return_success
        cmp     [esp], eax
        jnz     .return_success
        mov     edx, esp
        push    0xDEADFEFF
        mov     ecx, esp
        invoke  WriteFile, esi, ecx, 2, edx, NULL
        add     esp, 8
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_success:
        mov     eax, TRUE
        add     esp, 4
        pop     esi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetStdOutCurrentPosition
        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .return
        push    esi
        mov     esi, eax
        lea     ecx, [esp-4]
        invoke  GetConsoleMode, eax, ecx
        test    eax, eax
        jz      .get_file_offset
        sub     esp, sizeof.CONSOLE_SCREEN_BUFFER_INFO
        invoke  GetConsoleScreenBufferInfo, esi, esp
        test    eax, eax
        jz      @f
        mov     eax, [esp+CONSOLE_SCREEN_BUFFER_INFO.dwCursorPosition]
        add     esp, sizeof.CONSOLE_SCREEN_BUFFER_INFO
        pop     esi

.return:
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     eax, -1
        add     esp, sizeof.CONSOLE_SCREEN_BUFFER_INFO
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.get_file_offset:
        invoke  SetFilePointer, esi, eax, eax, FILE_CURRENT
        pop     esi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutClear

__stack_length = 2 + sizeof.CONSOLE_SCREEN_BUFFER_INFO + 4

__csbi = 4

        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .return_zero
        push    ebx
        mov     ebx, eax
        push    esi
        sub     esp, __stack_length
        lea     ecx, [esp+__csbi]
        invoke  GetConsoleScreenBufferInfo, eax, ecx
        test    eax, eax
        jz      .restore_stack_and_return
        movzx   eax, word [esp+__csbi+CONSOLE_SCREEN_BUFFER_INFO.dwSize.X]
        movzx   ecx, word [esp+__csbi+CONSOLE_SCREEN_BUFFER_INFO.dwSize.Y]
        mul     ecx
        mov     esi, eax
        invoke  FillConsoleOutputCharacter, ebx, dword ' ', eax, edx, esp
        test    eax, eax
        jz      .restore_stack_and_return
        movzx   eax, word [esp+__csbi+CONSOLE_SCREEN_BUFFER_INFO.wAttributes]
        invoke  FillConsoleOutputAttribute, ebx, eax, esi, 0, esp
        test    eax, eax
        jz      .restore_stack_and_return
        invoke  SetConsoleCursorPosition, ebx, 0

.restore_stack_and_return:
        add     esp, __stack_length
        pop     esi ebx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_zero:
        xor     eax, eax
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc SetStdOutCurrentPosition

_position = 4

        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .return
        push    esi
        mov     esi, eax
        lea     ecx, [esp-4]
        invoke  GetConsoleMode, eax, ecx
        test    eax, eax
        jz      .set_file_offset
        invoke  SetConsoleCursorPosition, esi, dword [esp+4+_position]
        test    eax, eax
        jz      @f
        mov     eax, [esp+4+_position]
        pop     esi

.return:
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     eax, -1
        pop     esi
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.set_file_offset:
        invoke  SetFilePointer, esi, dword [esp+8+4+_position], eax, FILE_BEGIN
        push    esi
        mov     esi, eax
        call    [SetEndOfFile]
        mov     eax, esi
        pop     esi
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutWriteA

_lpBuffer = 4
_nNumberOfCharsToWrite = 8

        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        cmp     eax, INVALID_HANDLE_VALUE
        jz      @f
        push    esi eax
        mov     esi, eax
        invoke  GetConsoleMode, eax, esp
        test    eax, eax
        mov     edx, esp
        jz      .write_to_file
        invoke  WriteConsoleA, esi, dword [esp+12+8+_lpBuffer], dword [esp+8+8+_nNumberOfCharsToWrite], edx, NULL
        test    eax, eax
        jz      .return_error_code
        pop     eax esi
    @@:
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_to_file:
        invoke  WriteFile, esi, dword [esp+12+8+_lpBuffer], dword [esp+8+8+_nNumberOfCharsToWrite], edx, eax
        test    eax, eax
        jz      .return_error_code
        pop     eax esi
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        dec     eax
        add     esp, 4
        pop     esi
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutWriteExA

_lpBuffer = 4
_nNumberOfCharsToWrite = 8
_isWriteToFile = 12

        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        cmp     eax, INVALID_HANDLE_VALUE
        jz      @f
        push    esi eax
        mov     esi, eax
        invoke  GetConsoleMode, eax, esp
        test    eax, eax
        mov     edx, esp
        jz      .write_to_file
        invoke  WriteConsoleA, esi, dword [esp+12+8+_lpBuffer], dword [esp+8+8+_nNumberOfCharsToWrite], edx, NULL
        test    eax, eax
        jz      .return_error_code
        pop     eax esi
    @@:
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_to_file:
        cmp     [esp+8+_isWriteToFile], eax
        jz      @f
        invoke  WriteFile, esi, dword [esp+12+8+_lpBuffer], dword [esp+8+8+_nNumberOfCharsToWrite], edx, eax
        test    eax, eax
        jz      .return_error_code
        pop     eax esi
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        dec     eax
    @@: add     esp, 4
        pop     esi
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutWriteW

_lpBuffer = 4
_nNumberOfCharsToWrite = 8

        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        cmp     eax, INVALID_HANDLE_VALUE
        jz      @f
        push    esi eax
        mov     esi, eax
        invoke  GetConsoleMode, eax, esp
        test    eax, eax
        mov     edx, esp
        jz      .write_to_file
        invoke  WriteConsoleW, esi, dword [esp+12+8+_lpBuffer], dword [esp+8+8+_nNumberOfCharsToWrite], edx, NULL
        test    eax, eax
        jz      .return_error_code
        pop     eax esi
    @@:
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_to_file:
        mov     ecx, [esp+8+_nNumberOfCharsToWrite]
        add     ecx, ecx
        invoke  WriteFile, esi, dword [esp+12+8+_lpBuffer], ecx, edx, eax
        test    eax, eax
        jz      .return_error_code
        pop     eax
        shr     eax, 1
        pop     esi
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        dec     eax
        add     esp, 4
        pop     esi
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutWriteExW

_lpBuffer = 4
_nNumberOfCharsToWrite = 8
_isWriteToFile = 12

        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        cmp     eax, INVALID_HANDLE_VALUE
        jz      @f
        push    esi eax
        mov     esi, eax
        invoke  GetConsoleMode, eax, esp
        test    eax, eax
        mov     edx, esp
        jz      .write_to_file
        invoke  WriteConsoleW, esi, dword [esp+12+8+_lpBuffer], dword [esp+8+8+_nNumberOfCharsToWrite], edx, NULL
        test    eax, eax
        jz      .return_error_code
        pop     eax esi
    @@:
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_to_file:
        cmp     [esp+8+_isWriteToFile], eax
        jz      @f
        mov     ecx, [esp+8+_nNumberOfCharsToWrite]
        add     ecx, ecx
        invoke  WriteFile, esi, dword [esp+12+8+_lpBuffer], ecx, edx, eax
        test    eax, eax
        jz      .return_error_code
        pop     eax
        shr     eax, 1
        pop     esi
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        dec     eax
    @@: add     esp, 4
        pop     esi
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintA

_lpBuffer = 4

        push    ecx ecx
        stdcall c_strlen, dword [esp+8+_lpBuffer]
        test    eax, eax
        mov     [esp+8], eax
        jz      @f
        mov     [esp+4], eax
        stdcall StdOutWriteA
        pop     ecx
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        add     esp, 8
        pop     ecx
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintExA

_lpBuffer = 4
_isWriteToFile = 8

        push    ecx
        push    dword [esp+4+_isWriteToFile]
        push    ecx
        stdcall c_strlen, dword [esp+12+_lpBuffer]
        test    eax, eax
        mov     [esp+12], eax
        jz      @f
        mov     [esp+4], eax
        stdcall StdOutWriteExA
        pop     ecx
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        add     esp, 12
        pop     ecx
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintExW

_lpBuffer = 4
_isWriteToFile = 8

        push    ecx
        push    dword [esp+4+_isWriteToFile]
        push    ecx
        stdcall c_wcslen, dword [esp+12+_lpBuffer]
        test    eax, eax
        mov     [esp+12], eax
        jz      @f
        mov     [esp+4], eax
        stdcall StdOutWriteExW
        pop     ecx
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        add     esp, 12
        pop     ecx
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintW

_lpBuffer = 4

        push    ecx ecx
        stdcall c_wcslen, dword [esp+8+_lpBuffer]
        test    eax, eax
        mov     [esp+8], eax
        jz      @f
        mov     [esp+4], eax
        stdcall StdOutWriteW
        pop     ecx
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        add     esp, 8
        pop     ecx
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintFormattedA

_format = 4
_args = 8

        push    ebx edi
        xor     ebx, ebx
        mov     edi, ebx
    @@: lea     eax, [esp+8+_args]
        cinvoke _vsnprintf, edi, ebx, dword [esp+4+8+_format], eax
        test    edi, edi
        jnz     @f
        cmp     eax, -1
        jz      .restore_registers
        inc     eax
        mov     ebx, eax
        stdcall ProcessHeapAlloc, HEAP_ZERO_MEMORY, eax
        test    eax, eax
        jz      .return_error_code
        mov     edi, eax
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        cmp     eax, -1
        jz      .free_string_heap_and_return_error_code
        dec     ebx
        stdcall StdOutWriteA, edi, ebx

.restore_registers:
        pop     edi ebx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.free_string_heap_and_return_error_code:
        stdcall ProcessHeapFree, edi

.return_error_code:
        mov     eax, -1
        jmp     .restore_registers
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintFormattedW

_format = 4
_args = 8

        push    ebx edi
        xor     ebx, ebx
        mov     edi, ebx
    @@: lea     eax, [esp+8+_args]
        cinvoke _vsnwprintf, edi, ebx, dword [esp+4+8+_format], eax
        test    edi, edi
        jnz     @f
        cmp     eax, -1
        jz      .restore_registers
        inc     eax
        mov     ebx, eax
        add     eax, eax
        stdcall ProcessHeapAlloc, HEAP_ZERO_MEMORY, eax
        test    eax, eax
        jz      .return_error_code
        mov     edi, eax
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        cmp     eax, -1
        jz      .free_string_heap_and_return_error_code
        dec     ebx
        stdcall StdOutWriteW, edi, ebx

.restore_registers:
        pop     edi ebx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.free_string_heap_and_return_error_code:
        stdcall ProcessHeapFree, edi

.return_error_code:
        mov     eax, -1
        jmp     .restore_registers
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintLowerCaseHexadecimalA

_value = 4

__stack_size = 8 + 1 + 3

        sub     esp, __stack_size
        mov     eax, esp
        ccall   xtola, eax, 0, dword [esp+__stack_size+_value]
        mov     ecx, esp
        stdcall StdOutWriteA, ecx, eax
        add     esp, __stack_size
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintLowerCaseHexadecimalW

_value = 4

__stack_size = ((8 + 1) * 2) + 2

        sub     esp, __stack_size
        mov     eax, esp
        ccall   xtolw, eax, 0, dword [esp+__stack_size+_value]
        mov     ecx, esp
        stdcall StdOutWriteW, ecx, eax
        add     esp, __stack_size
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintUpperCaseHexadecimalA

_value = 4

__stack_size = 8 + 1 + 3

        sub     esp, __stack_size
        mov     eax, esp
        ccall   xtoua, eax, 0, dword [esp+__stack_size+_value]
        mov     ecx, esp
        stdcall StdOutWriteA, ecx, eax
        add     esp, __stack_size
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintUpperCaseHexadecimalExA

_val = 4
_len = 8

__stack_size = 8 + 1 + 3

        mov     ecx, [esp+_len]
        cmp     ecx, 8
        jna     @f
        mov     ecx, 8
    @@: sub     esp, __stack_size
        mov     eax, esp
        ccall   xtoua, eax, ecx, dword [esp+__stack_size+_val]
        mov     ecx, esp
        stdcall StdOutWriteA, ecx, eax
        add     esp, __stack_size
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintUpperCaseHexadecimalW

_value = 4

__stack_size = ((8 + 1) * 2) + 2

        sub     esp, __stack_size
        mov     eax, esp
        ccall   xtouw, eax, 0, dword [esp+__stack_size+_value]
        mov     ecx, esp
        stdcall StdOutWriteW, ecx, eax
        add     esp, __stack_size
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintUpperCaseHexadecimalExW

_val = 4
_len = 8

__stack_size = ((8 + 1) * 2) + 2

        mov     ecx, [esp+_len]
        cmp     ecx, 8
        jna     @f
        mov     ecx, 8
    @@: sub     esp, __stack_size
        mov     eax, esp
        ccall   xtouw, eax, ecx, dword [esp+__stack_size+_val]
        mov     ecx, esp
        stdcall StdOutWriteW, ecx, eax
        add     esp, __stack_size
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintUnsignedIntegerA

_UnsignedIntegerValue = 4

__stack_size = (10 + 1) + 1

        sub     esp, __stack_size
        mov     eax, esp
        ccall   c_ultoa, dword [esp+8+__stack_size+_UnsignedIntegerValue], eax, 10
        stdcall StdOutPrintA, esp
        add     esp, __stack_size
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutPrintUnsignedIntegerW

_UnsignedIntegerValue = 4

__stack_size = ((10 + 1) * 2) + 2

        sub     esp, __stack_size
        mov     eax, esp
        ccall   c_ultow, dword [esp+8+__stack_size+_UnsignedIntegerValue], eax, 10
        stdcall StdOutPrintW, esp
        add     esp, __stack_size
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutErrorCodePrintA
        push    ebx edi esi
        mov     esi, ecx
        mov     edi, eax
        mov     ebx, 18 + 2
        sub     esp, ebx
        xor     eax, eax
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .errcode
        else
        test    ecx, ecx
        jz      .errcode
        end if
        ccall   c_strlen, ecx
        test    eax, eax
        jz      .errcode
        test    eax, 11b
        mov     edx, eax
        jz      @f
        and     edx, 11111111111111111111111111111100b
        add     edx, 100b
    @@: add     ebx, edx
        sub     esp, edx
        mov     ecx, esp
        push    eax
        push    esi
        mov     esi, eax
        push    ecx
        call    c_memcpy
        mov     eax, esi
        add     esp, 12
        mov     byte [esp+eax], ' '
        inc     eax

.errcode:
        lea     esi, [esp+eax]
        mov     dword [esi], 'Code'
        mov     dword [esi+4], ': 0x'
        add     esi, 8
        ccall   xtoua, esi, 8, edi
        mov     word [esi+8], EOL_LF
        stdcall StdOutPrintA, esp
        cmp     eax, -1
        jz      @f
        add     esp, ebx
        pop     esi edi ebx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        xor     eax, eax
        mov     [esi+8], al
        invoke  MessageBoxA, eax, edi, eax, MB_ICONERROR or MB_OK
        add     esp, ebx
        pop     esi edi ebx
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc StdOutErrorCodePrintW
        push    ebx edi esi
        mov     esi, ecx
        mov     edi, eax
        mov     ebx, 18 * 2
        sub     esp, ebx
        xor     eax, eax
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .errcode
        else
        test    ecx, ecx
        jz      .errcode
        end if
        ccall   c_wcslen, ecx
        test    eax, eax
        jz      .errcode
        add     eax, eax
        mov     edx, eax
        bt      ax, 1
        jnc     @f
        and     edx, 11111111111111111111111111111100b
        add     edx, 100b
    @@: sub     esp, edx
        add     ebx, edx
        mov     ecx, esp
        push    eax
        push    esi
        mov     esi, eax
        push    ecx
        call    c_memcpy
        mov     eax, esi
        add     esp, 12
        mov     word [esp+eax], ' '
        add     eax, 2

.errcode:
        lea     esi, [esp+eax]
        mov     dword [esi], 'C' or ('o' shl 16)
        mov     dword [esi+4], 'd' or ('e' shl 16)
        mov     dword [esi+8], ':' or (' ' shl 16)
        mov     dword [esi+12], '0' or ('x' shl 16)
        add     esi, 8 * 2
        ccall   xtouw, esi, 8, edi
        mov     dword [esi+(8*2)], EOL_LF
        stdcall StdOutPrintW, esp
        cmp     eax, -1
        jz      @f
        add     esp, ebx
        pop     esi edi ebx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        xor     eax, eax
        mov     [esi+(8*2)], ax
        invoke  MessageBoxW, eax, edi, eax, MB_ICONERROR or MB_OK
        add     esp, ebx
        pop     esi edi ebx
        retn
endp

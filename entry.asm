; Pseudo C / entry.asm
; --------------------
; 31.03.2022 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc parsecmdargs.a
        push    ebp
        mov     ebp, ecx
        push    ebx esi edi
        invoke  GetCommandLineA
        mov     esi, eax
        mov     edi, eax
        xor     edx, edx
        mov     ebx, edx
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.command_line_analyzing_loop:
        inc     edi
    @@: mov     al, [edi]
        test    al, al
        jz      .command_line_analyzing_end
        cmp     al, 9
        jz      .command_line_analyzing_loop
        cmp     al, ' '
        jz      .command_line_analyzing_loop
        cmp     al, '"'
        jz      .argument_in_quotes_analyzing
        mov     ecx, edi
        inc     edi

.regular_argument_analyzing_loop:
        mov     al, [edi]
        test    al, al
        jz      .last_argument
        cmp     al, 9
        jz      .is_argument
        cmp     al, ' '
        jz      .is_argument
        inc     edi
        cmp     al, '"'
        jnz     .regular_argument_analyzing_loop
    @@: mov     al, [edi]
        test    al, al
        jz      .last_argument
        inc     edi
        cmp     al, '"'
        jnz     @b
        jmp     .regular_argument_analyzing_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.argument_in_quotes_analyzing:
        inc     edi
        mov     ecx, edi
    @@: mov     al, [edi]
        test    al, al
        jz      .last_argument
        cmp     al, '"'
        jz      .is_argument
        inc     edi
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.is_argument:
        sub     ecx, edi
        jz      .command_line_analyzing_loop
        sub     ebx, ecx
        inc     edx
        jmp     .command_line_analyzing_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.last_argument:
        sub     ecx, edi
        jz      .command_line_analyzing_end
        sub     ebx, ecx
        inc     edx
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.command_line_analyzing_end:
        test    edx, edx
        jz      .error_bad_arguments
    @@: add     ebx, edx
        mov     [ebp+C_MAINCMDARGS.argc], edx
        lea     eax, [ebx+edx*4]
        mov     ebx, edx
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_memory_block
        mov     [ebp+C_MAINCMDARGS.argv], eax
        lea     edi, [eax+ebx*4]
        mov     edx, eax
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.arguments_array_filling_loop:
        inc     esi
    @@: mov     al, [esi]
        test    al, al
        jz      .arguments_array_filling_end
        cmp     al, 9
        jz      .arguments_array_filling_loop
        cmp     al, ' '
        jz      .arguments_array_filling_loop
        cmp     al, '"'
        jz      .argument_in_quotes
        mov     [edi], al
        mov     ecx, 1

.regular_argument_processing_loop:
        inc     esi
        mov     al, [esi]
        test    al, al
        jz      .last_array_item
        cmp     al, 9
        jz      .is_array_item
        cmp     al, ' '
        jz      .is_array_item
        mov     [edi+ecx], al
        inc     ecx
        cmp     al, '"'
        jnz     .regular_argument_processing_loop
    @@: inc     esi
        mov     al, [esi]
        test    al, al
        jz      .last_array_item
        mov     [edi+ecx], al
        inc     ecx
        cmp     al, '"'
        jnz     @b
        jmp     .regular_argument_processing_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.argument_in_quotes:
        xor     ecx, ecx
    @@: inc     esi
        mov     al, [esi]
        test    al, al
        jz      .last_array_item
        cmp     al, '"'
        jz      .is_array_item
        mov     [edi+ecx], al
        inc     ecx
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.is_array_item:
        test    ecx, ecx
        jz      .arguments_array_filling_loop
        mov     [edx], edi
        add     edx, 4
        add     edi, ecx
        mov     byte [edi], 0
        inc     edi
        jmp     .arguments_array_filling_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.last_array_item:
        test    ecx, ecx
        jz      .arguments_array_filling_end
        mov     [edx], edi
        mov     byte [edi+ecx], 0

.arguments_array_filling_end:
        xor     eax, eax

.restore_stack_and_return:
        pop     edi esi ebx ebp
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_bad_arguments:
        invoke  SetLastError, ERROR_BAD_ARGUMENTS
        mov     eax, ERROR_BAD_ARGUMENTS
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_memory_block:
        invoke  GetLastError
        jmp     .restore_stack_and_return
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc parsecmdargs.w
        push    ebp
        mov     ebp, ecx
        push    ebx esi edi
        invoke  GetCommandLineW
        mov     esi, eax
        mov     edi, eax
        xor     edx, edx
        mov     ebx, edx
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.command_line_analyzing_loop:
        add     edi, 2
    @@: mov     ax, [edi]
        test    ax, ax
        jz      .command_line_analyzing_end
        cmp     ax, 9
        jz      .command_line_analyzing_loop
        cmp     ax, ' '
        jz      .command_line_analyzing_loop
        cmp     ax, '"'
        jz      .argument_in_quotes_analyzing
        mov     ecx, edi
        add     edi, 2

.regular_argument_analyzing_loop:
        mov     ax, [edi]
        test    ax, ax
        jz      .last_argument
        cmp     ax, 9
        jz      .is_argument
        cmp     ax, ' '
        jz      .is_argument
        add     edi, 2
        cmp     ax, '"'
        jnz     .regular_argument_analyzing_loop
    @@: mov     ax, [edi]
        test    ax, ax
        jz      .last_argument
        add     edi, 2
        cmp     ax, '"'
        jnz     @b
        jmp     .regular_argument_analyzing_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.argument_in_quotes_analyzing:
        add     edi, 2
        mov     ecx, edi
    @@: mov     ax, [edi]
        test    ax, ax
        jz      .last_argument
        cmp     ax, '"'
        jz      .is_argument
        add     edi, 2
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.is_argument:
        sub     ecx, edi
        jz      .command_line_analyzing_loop
        sub     ebx, ecx
        inc     edx
        jmp     .command_line_analyzing_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.last_argument:
        sub     ecx, edi
        jz      .command_line_analyzing_end
        sub     ebx, ecx
        inc     edx
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.command_line_analyzing_end:
        test    edx, edx
        jz      .error_bad_arguments
    @@: mov     [ebp+C_MAINCMDARGS.argc], edx
        lea     eax, [ebx+edx*2]
        lea     eax, [eax+edx*4]
        mov     ebx, edx
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_memory_block
        mov     [ebp+C_MAINCMDARGS.argv], eax
        lea     edi, [eax+ebx*4]
        mov     edx, eax
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.arguments_array_filling_loop:
        add     esi, 2
    @@: mov     ax, [esi]
        test    ax, ax
        jz      .arguments_array_filling_end
        cmp     ax, 9
        jz      .arguments_array_filling_loop
        cmp     ax, ' '
        jz      .arguments_array_filling_loop
        cmp     ax, '"'
        jz      .argument_in_quotes
        mov     [edi], ax
        mov     ecx, 2

.regular_argument_processing_loop:
        add     esi, 2
        mov     ax, [esi]
        test    ax, ax
        jz      .last_array_item
        cmp     ax, 9
        jz      .is_array_item
        cmp     ax, ' '
        jz      .is_array_item
        mov     [edi+ecx], ax
        add     ecx, 2
        cmp     ax, '"'
        jnz     .regular_argument_processing_loop
    @@: add     esi, 2
        mov     ax, [esi]
        test    ax, ax
        jz      .last_array_item
        mov     [edi+ecx], ax
        add     ecx, 2
        cmp     ax, '"'
        jnz     @b
        jmp     .regular_argument_processing_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.argument_in_quotes:
        xor     ecx, ecx
    @@: add     esi, 2
        mov     ax, [esi]
        test    ax, ax
        jz      .last_array_item
        cmp     ax, '"'
        jz      .is_array_item
        mov     [edi+ecx], ax
        add     ecx, 2
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.is_array_item:
        test    ecx, ecx
        jz      .arguments_array_filling_loop
        mov     [edx], edi
        add     edx, 4
        add     edi, ecx
        mov     word [edi], 0
        add     edi, 2
        jmp     .arguments_array_filling_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.last_array_item:
        test    ecx, ecx
        jz      .arguments_array_filling_end
        mov     [edx], edi
        mov     word [edi+ecx], 0

.arguments_array_filling_end:
        xor     eax, eax

.restore_stack_and_return:
        pop     edi esi ebx ebp
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_bad_arguments:
        invoke  SetLastError, ERROR_BAD_ARGUMENTS
        mov     eax, ERROR_BAD_ARGUMENTS
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_memory_block:
        invoke  GetLastError
        jmp     .restore_stack_and_return
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc fatalerrmsg.a
        sub     esp, 28
        mov     dword [esp], 'FATA'
        mov     dword [esp+4], 'L ER'
        mov     dword [esp+8], 'ROR:'
        mov     dword [esp+12], ' 0x '
        lea     ecx, [esp+15]
        ccall   xtoua, ecx, 8, eax
        mov     word [esp+23], EOL_CR or (EOL_LF shl 8)
        mov     byte [esp+25], 0
        stdcall StdOutPrintA, esp
        cmp     eax, -1
        jz      @f
        add     esp, 28
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     edx, esp
        xor     eax, eax
        mov     [edx+23], al
        invoke  MessageBoxA, eax, edx, eax, MB_ICONERROR or MB_OK
        add     esp, 28
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc fatalerrmsg.w
        sub     esp, 52
        mov     dword [esp], 'F' or ('A' shl 16)
        mov     dword [esp+4], 'T' or ('A' shl 16)
        mov     dword [esp+8], 'L' or (' ' shl 16)
        mov     dword [esp+12], 'E' or ('R' shl 16)
        mov     dword [esp+16], 'R' or ('O' shl 16)
        mov     dword [esp+20], 'R' or (':' shl 16)
        mov     dword [esp+24], ' ' or ('0' shl 16)
        mov     word [esp+28], 'x'
        lea     ecx, [esp+30]
        ccall   xtouw, ecx, 8, eax
        mov     dword [esp+46], EOL_CR or (EOL_LF shl 16)
        mov     word [esp+50], 0
        stdcall StdOutPrintW, esp
        cmp     eax, -1
        jz      @f
        add     esp, 52
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     edx, esp
        xor     eax, eax
        mov     [edx+46], ax
        invoke  MessageBoxW, eax, edx, eax, MB_ICONERROR or MB_OK
        add     esp, 52
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc fatalerrmsgbox.a
        sub     esp, 24
        mov     dword [esp], 'FATA'
        mov     dword [esp+4], 'L ER'
        mov     dword [esp+8], 'ROR:'
        mov     dword [esp+12], ' 0x '
        lea     ecx, [esp+15]
        ccall   xtoua, ecx, 8, eax
        mov     edx, esp
        xor     al, al
        invoke  MessageBoxA, eax, edx, eax, MB_ICONERROR or MB_OK
        add     esp, 24
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc fatalerrmsgbox.w
        sub     esp, 48
        mov     dword [esp], 'F' or ('A' shl 16)
        mov     dword [esp+4], 'T' or ('A' shl 16)
        mov     dword [esp+8], 'L' or (' ' shl 16)
        mov     dword [esp+12], 'E' or ('R' shl 16)
        mov     dword [esp+16], 'R' or ('O' shl 16)
        mov     dword [esp+20], 'R' or (':' shl 16)
        mov     dword [esp+24], ' ' or ('0' shl 16)
        mov     word [esp+28], 'x'
        lea     ecx, [esp+30]
        ccall   xtouw, ecx, 8, eax
        mov     edx, esp
        xor     al, al
        invoke  MessageBoxW, eax, edx, eax, MB_ICONERROR or MB_OK
        add     esp, 48
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc SetBaseConsoleCodePage
        if defined PSEUDO_C_USE_FSNTLPS & PSEUDO_C_USE_FSNTLPS eq TRUE
        invoke  FSNTLPS_AreFileApisANSI
        else
        invoke  AreFileApisANSI
        end if
        test    eax, eax
        jz      .oem_codepage
        invoke  GetACP
    @@: push    eax
        invoke  SetConsoleOutputCP, eax
        test    eax, eax
        jz      .error_unable_to_set_console_output_codepage
        call    [SetConsoleCP]
        test    eax, eax
        jz      .error_unable_to_set_console_codepage
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.oem_codepage:
        invoke  GetOEMCP
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_set_console_output_codepage:
        pop     ecx

.error_unable_to_set_console_codepage:
        invoke  GetLastError
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc entry.console.a

__return = sizeof.C_MAINCMDARGS

        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        sub     esp, sizeof.C_MAINCMDARGS
        invoke  __set_app_type, _CONSOLE_APP
        else
        sub     esp, sizeof.C_MAINCMDARGS + 4
        end if
        call    SetBaseConsoleCodePage
        test    eax, eax
        jnz     .internal_error
        tcall   parsecmdargs.a, esp
        test    eax, eax
        jnz     .internal_error
        stdcall main, dword [esp+4+C_MAINCMDARGS.argc], dword [esp+C_MAINCMDARGS.argv]
        mov     [esp+8+__return], eax
        add     esp, 4
        call    ProcessHeapFree
    @@: add     esp, sizeof.C_MAINCMDARGS
        if defined PSEUDO_C_USE_ONLY_WINAPI & PSEUDO_C_USE_ONLY_WINAPI eq TRUE
        call    [ExitProcess]
        else
        call    [_exit]
        end if
        int3

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.internal_error:
        mov     [esp+__return], eax
        call    fatalerrmsg.a
        jmp     @b
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc entry.console.w

__return = sizeof.C_MAINCMDARGS

        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        sub     esp, sizeof.C_MAINCMDARGS
        invoke  __set_app_type, _CONSOLE_APP
        else
        sub     esp, sizeof.C_MAINCMDARGS + 4
        end if
        call    PrepareStdOutW
        test    eax, eax
        jz      .get_last_system_error_code
        tcall   parsecmdargs.w, esp
        test    eax, eax
        jnz     .internal_error
        stdcall main, dword [esp+4+C_MAINCMDARGS.argc], dword [esp+C_MAINCMDARGS.argv]
        mov     [esp+8+__return], eax
        add     esp, 4
        call    ProcessHeapFree
    @@: add     esp, sizeof.C_MAINCMDARGS
        if defined PSEUDO_C_USE_ONLY_WINAPI & PSEUDO_C_USE_ONLY_WINAPI eq TRUE
        call    [ExitProcess]
        else
        call    [_exit]
        end if
        int3

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.get_last_system_error_code:
        invoke  GetLastError

.internal_error:
        mov     [esp+__return], eax
        call    fatalerrmsg.w
        jmp     @b
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc entry.gui.a

__return = sizeof.C_MAINCMDARGS

        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        sub     esp, sizeof.C_MAINCMDARGS
        invoke  __set_app_type, _GUI_APP
        else
        sub     esp, sizeof.C_MAINCMDARGS + 4
        end if
        tcall   parsecmdargs.a, esp
        test    eax, eax
        jnz     .internal_error
        stdcall main, dword [esp+4+C_MAINCMDARGS.argc], dword [esp+C_MAINCMDARGS.argv]
        mov     [esp+8+__return], eax
        add     esp, 4
        call    ProcessHeapFree
    @@: add     esp, sizeof.C_MAINCMDARGS
        if defined PSEUDO_C_USE_ONLY_WINAPI & PSEUDO_C_USE_ONLY_WINAPI eq TRUE
        call    [ExitProcess]
        else
        call    [_exit]
        end if
        int3

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.internal_error:
        mov     [esp+__return], eax
        call    fatalerrmsgbox.a
        jmp     @b
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc entry.gui.w

__return = sizeof.C_MAINCMDARGS

        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        sub     esp, sizeof.C_MAINCMDARGS
        invoke  __set_app_type, _GUI_APP
        else
        sub     esp, sizeof.C_MAINCMDARGS + 4
        end if
        tcall   parsecmdargs.w, esp
        test    eax, eax
        jnz     .internal_error
        stdcall main, dword [esp+4+C_MAINCMDARGS.argc], dword [esp+C_MAINCMDARGS.argv]
        mov     [esp+8+__return], eax
        add     esp, 4
        call    ProcessHeapFree
    @@: add     esp, sizeof.C_MAINCMDARGS
        if defined PSEUDO_C_USE_ONLY_WINAPI & PSEUDO_C_USE_ONLY_WINAPI eq TRUE
        call    [ExitProcess]
        else
        call    [_exit]
        end if
        int3

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.internal_error:
        mov     [esp+__return], eax
        call    fatalerrmsgbox.w
        jmp     @b
endp

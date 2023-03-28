; Pseudo C / xtox.asm
; -------------------
; 11.08.2022 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_xtoxa

_value = 4
_buffer = 8
_radix = 12
_is_neg = 16

        cmp     dword [esp+_is_neg], FALSE
        mov     eax, [esp+_value]
        push    esi
        mov     esi, [esp+4+_buffer]
        push    edi
        jz      @f
        mov     byte [esi], '-'
        inc     esi
        neg     eax
    @@: mov     edi, esi
 .loop: xor     edx, edx
        div     dword [esp+8+_radix]
        cmp     edx, 9
        jna     @f
        add     dl, 39 ; "'"
    @@: add     dl, '0'
        mov     [esi], dl
        inc     esi
        test    eax, eax
        jnz     .loop
        mov     [esi], al
        dec     esi
    @@: mov     al, [edi]
        mov     cl, [esi]
        mov     [esi], al
        dec     esi
        mov     [edi], cl
        inc     edi
        cmp     edi, esi
        jb      @b
        pop     edi esi
        retn    16
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_xtoxw

_value = 4
_buffer = 8
_radix = 12
_is_neg = 16

        cmp     dword [esp+_is_neg], FALSE
        mov     ecx, [esp+_value]
        push    ebx esi
        mov     esi, [esp+8+_buffer]
        push    edi
        jz      @f
        mov     word [esi], '-'
        add     esi, 2
        neg     ecx
    @@: mov     ebx, 2
        mov     edi, esi
 .loop: mov     eax, ecx
        xor     edx, edx
        div     dword [esp+12+_radix]
        mov     ecx, eax
        lea     eax, [edx+'W']
        cmp     edx, 9
        ja      @f
        lea     eax, [edx+'0']
    @@: mov     [esi], ax
        add     esi, ebx
        test    ecx, ecx
        jnz     .loop
        xor     eax, eax
        mov     [esi], ax
        sub     esi, ebx
    @@: mov     ax, [edi]
        movzx   ecx, word [esi]
        mov     [esi], ax
        sub     esi, ebx
        mov     [edi], cx
        add     edi, ebx
        cmp     edi, esi
        jb      @b
        pop     edi esi ebx
        retn    16
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_itoa

_value = 4
_buffer = 8
_radix = 12

        cmp     dword [esp+_radix], 10
        mov     eax, [esp+_value]
        push    esi
        mov     esi, [esp+4+_buffer]
        jnz     @f
        test    eax, eax
        js      .is_negative_value
    @@: stdcall c_xtoxa, eax, esi, dword [esp+4+4+_radix], FALSE
        mov     eax, esi
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.is_negative_value:
        stdcall c_xtoxa, eax, esi, 10, TRUE
        mov     eax, esi
        pop     esi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_itow

_value = 4
_buffer = 8
_radix = 12

        cmp     dword [esp+_radix], 10
        mov     eax, [esp+_value]
        push    esi
        mov     esi, [esp+4+_buffer]
        jnz     @f
        test    eax, eax
        js      .is_negative_value
    @@: stdcall c_xtoxw, eax, esi, dword [esp+4+4+_radix], FALSE
        mov     eax, esi
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.is_negative_value:
        stdcall c_xtoxw, eax, esi, 10, TRUE
        mov     eax, esi
        pop     esi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_ltoa

_value = 4
_buffer = 8
_radix = 12

        xor     eax, eax
        cmp     dword [esp+_radix], 10
        jnz     @f
        cmp     [esp+_value], eax
        jnl     @f
        inc     eax
    @@: stdcall c_xtoxa, dword [esp+12+_value], dword [esp+8+_buffer], dword [esp+4+_radix], eax
        mov     eax, [esp+_buffer]
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_ltow

_value = 4
_buffer = 8
_radix = 12

        xor     eax, eax
        cmp     dword [esp+_radix], 10
        jnz     @f
        cmp     [esp+_value], eax
        jnl     @f
        inc     eax
    @@: stdcall c_xtoxw, dword [esp+12+_value], dword [esp+8+_buffer], dword [esp+4+_radix], eax
        mov     eax, [esp+_buffer]
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_ultoa

_value = 4
_buffer = 8
_radix = 12

        stdcall c_xtoxa, dword [esp+12+_value], dword [esp+8+_buffer], dword [esp+4+_radix], FALSE
        mov     eax, [esp+_buffer]
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_ultow

_value = 4
_buffer = 8
_radix = 12

        stdcall c_xtoxw, dword [esp+12+_value], dword [esp+8+_buffer], dword [esp+4+_radix], FALSE
        mov     eax, [esp+_buffer]
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc atoui

_str = 4

        mov     ecx, [esp+_str]
        xor     eax, eax
        mov     edx, eax
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
 .loop:
        sub     dl, '0'
        lea     eax, [eax+eax*4]
        lea     eax, [edx+eax*2]
        inc     ecx
    @@: mov     dl, [ecx]
        cmp     dl, '0'
        jb      @f
        cmp     dl, '9'
        jna     .loop
    @@:
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc atoui_s

_str = 4
_chlen = 8

        mov     cl, [esp+_chlen]
        dec     cl
        push    esi
        mov     esi, [esp+4+_str]
        xor     eax, eax
        mov     edx, eax
        cmp     cl, 10 - 1
        jna     .read
        mov     cl, 10 - 1
        jmp     .read

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
 .loop:
        sub     dl, '0'
        lea     eax, [eax+eax*4]
        lea     eax, [edx+eax*2]
        dec     cl
        js      @f
        inc     esi
 .read: mov     dl, [esi]
        cmp     dl, '0'
        jb      @f
        cmp     dl, '9'
        jna     .loop
    @@: pop     esi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc Unsigned64bitIntegerToStringA

_lpLargeInteger = 4
_nBufferLength = 8
_lpBuffer = 12

        push    ebp
        mov     ebp, [esp+4+_lpBuffer]
        test    ebp, ebp
        jz      .error_invalid_buffer_pointer
        push    ebx
        mov     ebx, [esp+8+_nBufferLength]
        dec     ebx
        js      .error_bad_length
        jz      .write_empty_string
        mov     eax, [esp+8+_lpLargeInteger]
        test    eax, eax
        jz      .write_zero
        push    esi
        mov     esi, [eax+LARGE_INTEGER.LowPart]
        push    edi
        mov     edi, [eax+LARGE_INTEGER.HighPart]
        mov     ecx, 10
        call    .divide_subcall
        pop     edi esi
        mov     eax, ebp
        mov     byte [eax], 0
        sub     eax, [esp+8+_lpBuffer]

.restore_ebx_and_return:
        pop     ebx

.restore_ebp_and_return:
        pop     ebp
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_invalid_buffer_pointer:
        invoke  SetLastError, ERROR_INVALID_PARAMETER
        or      eax, -1
        jmp     .restore_ebp_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_bad_length:
        invoke  SetLastError, ERROR_BAD_LENGTH
        or      eax, -1
        jmp     .restore_ebx_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_empty_string:
        xor     eax, eax
        mov     [ebp], al
        jmp     .restore_ebx_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_zero:
        inc     eax
        mov     word [ebp], '0'
        jmp     .restore_ebx_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.divide_subcall:
        push    dx
        xor     edx, edx
        mov     eax, edi
        div     ecx
        mov     edi, eax
        mov     eax, esi
        div     ecx
        add     dl, '0'
        mov     esi, eax
        or      eax, edi
        jz      @f
        call    .divide_subcall
    @@: dec     ebx
        js      @f
        mov     [ebp], dl
        inc     ebp
    @@: pop     dx
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc Unsigned64bitIntegerToStringW

_lpLargeInteger = 4
_nBufferLength = 8
_lpBuffer = 12

        push    ebp
        mov     ebp, [esp+4+_lpBuffer]
        test    ebp, ebp
        jz      .error_invalid_buffer_pointer
        push    ebx
        mov     ebx, [esp+8+_nBufferLength]
        dec     ebx
        js      .error_bad_length
        jz      .write_empty_string
        mov     eax, [esp+8+_lpLargeInteger]
        test    eax, eax
        jz      .write_zero
        push    esi
        mov     esi, [eax+LARGE_INTEGER.LowPart]
        push    edi
        mov     edi, [eax+LARGE_INTEGER.HighPart]
        mov     ecx, 10
        call    .divide_subcall
        pop     edi esi
        mov     eax, ebp
        mov     word [eax], 0
        sub     eax, [esp+8+_lpBuffer]
        shr     eax, 1

.restore_ebx_and_return:
        pop     ebx

.restore_ebp_and_return:
        pop     ebp
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_invalid_buffer_pointer:
        invoke  SetLastError, ERROR_INVALID_PARAMETER
        or      eax, -1
        jmp     .restore_ebp_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_bad_length:
        invoke  SetLastError, ERROR_BAD_LENGTH
        or      eax, -1
        jmp     .restore_ebx_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_empty_string:
        xor     eax, eax
        mov     [ebp], ax
        jmp     .restore_ebx_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.write_zero:
        inc     eax
        mov     dword [ebp], '0'
        jmp     .restore_ebx_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.divide_subcall:
        push    dx
        xor     edx, edx
        mov     eax, edi
        div     ecx
        mov     edi, eax
        mov     eax, esi
        div     ecx
        add     dl, '0'
        mov     esi, eax
        or      eax, edi
        jz      @f
        call    .divide_subcall
    @@: dec     ebx
        js      @f
        mov     [ebp], dx
        add     ebp, 2
    @@: pop     dx
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc wtoui

_wcstr = 4

        mov     ecx, [esp+_wcstr]
        xor     eax, eax
        mov     edx, eax
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
 .loop:
        sub     dl, '0'
        lea     eax, [eax+eax*4]
        lea     eax, [edx+eax*2]
        add     ecx, 2
    @@: mov     dx, [ecx]
        cmp     dx, '0'
        jb      @f
        cmp     dx, '9'
        jna     .loop
    @@:
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc wtoui_s

_wcstr = 4
_chlen = 8

        mov     cl, [esp+_chlen]
        dec     cl
        push    esi
        mov     esi, [esp+4+_wcstr]
        xor     eax, eax
        mov     edx, eax
        cmp     cl, 10 - 1
        jna     .read
        mov     cl, 10 - 1
        jmp     .read

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
 .loop:
        sub     dl, '0'
        lea     eax, [eax+eax*4]
        lea     eax, [edx+eax*2]
        dec     cl
        js      @f
        add     esi, 2
 .read: mov     dx, [esi]
        cmp     dx, '0'
        jb      @f
        cmp     dx, '9'
        jna     .loop
    @@: pop     esi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc hexadecimal_symbols_lowercase
db '0123456789abcdef'
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc xtola

_buf = 4
_len = 8
_val = 12

        mov     ecx, [esp+_len]
        mov     eax, [esp+_val]
        push    edi
        mov     edi, [esp+4+_buf]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .detect_length
        else
        test    ecx, ecx
        jz      .detect_length
        end if
        cmp     ecx, 8
        ja      .fix_length
    @@: push    ecx
        xor     edx, edx
        mov     [edi+ecx], ch
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.detect_length:
        bsr     ecx, eax
        shr     cl, 2
        inc     cl
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.fix_length:
        mov     ecx, 8
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        shr     eax, 4
    @@: mov     dl, al
        and     dl, 0xF
        mov     dl, [hexadecimal_symbols_lowercase+edx]
        dec     ecx
        mov     [edi+ecx], dl
        jnz     .loop
        pop     eax edi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc xtolw

_buf = 4
_len = 8
_val = 12

        mov     ecx, [esp+_len]
        mov     eax, [esp+_val]
        push    edi
        mov     edi, [esp+4+_buf]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .detect_length
        else
        test    ecx, ecx
        jz      .detect_length
        end if
        cmp     ecx, 8
        ja      .fix_length
    @@: push    ecx
        xor     edx, edx
        mov     [edi+ecx*2], dx
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.detect_length:
        bsr     ecx, eax
        shr     cl, 2
        inc     cl
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.fix_length:
        mov     ecx, 8
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        shr     eax, 4
    @@: mov     dl, al
        and     dl, 0xF
        mov     dl, [hexadecimal_symbols_lowercase+edx]
        dec     ecx
        mov     [edi+ecx*2], dx
        jnz     .loop
        pop     eax edi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc hexadecimal_symbols_uppercase
db '0123456789ABCDEF'
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc xtoua

_buf = 4
_len = 8
_val = 12

        mov     ecx, [esp+_len]
        mov     eax, [esp+_val]
        push    edi
        mov     edi, [esp+4+_buf]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .detect_length
        else
        test    ecx, ecx
        jz      .detect_length
        end if
        cmp     ecx, 8
        ja      .fix_length
    @@: push    ecx
        xor     edx, edx
        mov     [edi+ecx], ch
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.detect_length:
        bsr     ecx, eax
        shr     cl, 2
        inc     cl
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.fix_length:
        mov     ecx, 8
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        shr     eax, 4
    @@: mov     dl, al
        and     dl, 0xF
        mov     dl, [hexadecimal_symbols_uppercase+edx]
        dec     ecx
        mov     [edi+ecx], dl
        jnz     .loop
        pop     eax edi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc xtouw

_buf = 4
_len = 8
_val = 12

        mov     ecx, [esp+_len]
        mov     eax, [esp+_val]
        push    edi
        mov     edi, [esp+4+_buf]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .detect_length
        else
        test    ecx, ecx
        jz      .detect_length
        end if
        cmp     ecx, 8
        ja      .fix_length
    @@: push    ecx
        xor     edx, edx
        mov     [edi+ecx*2], dx
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.detect_length:
        bsr     ecx, eax
        shr     cl, 2
        inc     cl
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.fix_length:
        mov     ecx, 8
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        shr     eax, 4
    @@: mov     dl, al
        and     dl, 0xF
        mov     dl, [hexadecimal_symbols_uppercase+edx]
        dec     ecx
        mov     [edi+ecx*2], dx
        jnz     .loop
        pop     eax edi
        retn
endp

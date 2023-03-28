; Pseudo C / string.asm
; ---------------------
; 24.08.2021 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_strcat_s

_dst = 4
_num = 8
_src = 12

        push    esi
        xor     eax, eax
        mov     edx, [esp+4+_dst]
        test    edx, edx
        jz      .einval
        mov     ecx, [esp+4+_num]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .einval
        else
        test    ecx, ecx
        jz      .einval
        end if
        mov     esi, [esp+4+_src]
        test    esi, esi
        jz      .einval_clr_dst
    @@: cmp     [edx], al
        jz      @f
        inc     edx
        dec     ecx
        jnz     @b
        mov     edx, [esp+4+_dst]

.einval_clr_dst:
        mov     [edx], al

.einval:
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        call    [_errno]
        mov     dword [eax], EINVAL
        end if
        mov     eax, EINVAL
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     al, [esi]
        inc     esi
        mov     [edx], al
        inc     edx
        test    al, al
        jz      @f
        dec     ecx
        jnz     @b
        mov     edx, [esp+4+_dst]
        mov     [edx], cl
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        call    [_errno]
        mov     dword [eax], ERANGE
        end if
        mov     eax, ERANGE
    @@: pop     esi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_strcmp

_str1 = 4
_str2 = 8

        mov     ecx, [esp+_str2]
        mov     edx, [esp+_str1]
        test    edx, 1b
        jz      @f
        mov     al, [edx]
        cmp     al, [ecx]
        jnz     .epilog
        test    al, al
        jz      .eqstrs
        inc     ecx
        inc     edx
    @@: test    edx, 10b
        jz      .loop
        mov     ax, [edx]
        cmp     al, [ecx]
        jnz     .epilog
        test    al, al
        jz      .eqstrs
        cmp     ah, [ecx+1]
        jnz     .epilog
        test    ah, ah
        jz      .eqstrs
        add     ecx, 2
        add     edx, 2
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        add     ecx, 4
        add     edx, 4
    @@: mov     eax, [edx]
        cmp     al, [ecx]
        jnz     .epilog
        test    al, al
        jz      .eqstrs
        cmp     ah, [ecx+1]
        jnz     .epilog
        test    ah, ah
        jz      .eqstrs
        bswap   eax
        cmp     ah, [ecx+2]
        jnz     .epilog
        test    ah, ah
        jz      .eqstrs
        cmp     al, [ecx+3]
        jnz     .epilog
        test    al, al
        jnz     .loop

.eqstrs:
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.epilog:
        sbb     eax, eax
        add     eax, eax
        inc     eax
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_strncmp

_str1 = 4
_str2 = 8
_cnt = 12

        xor     eax, eax
        mov     ecx, [esp+_cnt]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .return
        else
        test    ecx, ecx
        jz      .return
        end if
        mov     edx, [esp+_str2]
        push    ebx
        mov     ebx, [esp+4+_str1]
        sub     ebx, edx
        jmp     @f

.general_loop:
        inc     edx
    @@: mov     al, [ebx+edx]
        cmp     al, [edx]
        jnz     @f
        test    al, al
        jz      @f
        dec     ecx
        jnz     .general_loop
    @@: movzx   ecx, byte [edx]
        sub     eax, ecx
        pop     ebx

.return:
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

if defined PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET & PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET eq TRUE

proc c_strcpy

_dst = 4
_src = 8

        push    esi
        mov     esi, [esp+4+_src]
        push    edi
        mov     edi, [esp+8+_dst]
        cld
    @@: lodsb
        stosb
        test    al, al
        jnz     @b
        pop     edi esi
        mov     eax, [esp+_dst]
        retn
endp

else

proc c_strcpy

_dst = 4
_src = 8

        mov     eax, [esp+_dst]
        mov     edx, [esp+_src]
        sub     eax, edx
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        inc     edx
    @@: mov     cl, [edx]
        mov     [eax+edx], cl
        test    cl, cl
        jnz     .loop
        mov     eax, [esp+_dst]
        retn
endp

end if

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_strcpy_s

_dst = 4
_len = 8
_src = 12

        push    edi
        mov     edi, [esp+4+_dst]
        test    edi, edi
        jz      .einval
        mov     ecx, [esp+4+_len]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .einval
        else
        test    ecx, ecx
        jz      .einval
        end if
        mov     edx, [esp+4+_src]
        test    edx, edx
        jz      .einval_clr_dst
        sub     edi, edx
        xor     eax, eax
    @@: mov     al, [edx]
        mov     [edi+edx], al
        test    al, al
        jz      @f
        inc     edx
        dec     ecx
        jnz     @b
        mov     edi, [esp+4+_dst]
        mov     [edi], cl
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        call    [_errno]
        mov     dword [eax], ERANGE
        end if
        mov     eax, ERANGE
    @@: pop     edi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.einval_clr_dst:
        mov     [edi], dl

.einval:
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        call    [_errno]
        mov     dword [eax], EINVAL
        end if
        mov     eax, EINVAL
        pop     edi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_strlen

_str = 4

        mov     eax, [esp+_str]
        test    eax, eax
        jnz     @f
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
 .loop:
        inc     eax
    @@: cmp     byte [eax], 0
        jnz     .loop
        sub     eax, [esp+_str]
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_strnlen

_str = 4
_cnt = 8

        mov     eax, [esp+_str]
        test    eax, eax
        jz      @f
        mov     ecx, [esp+_cnt]
        push    ecx
        shr     ecx, 2
        jnz     .multiple_byte_processing_loop
        pop     ecx
        and     cl, 11b
        jnz     .single_byte_processing
        mov     eax, ecx
    @@:
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        pop     ecx
        sub     eax, [esp+_str]
        bsf     edx, edx
        shr     edx, 3
        add     eax, edx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.multiple_byte_processing_loop:
        mov     edx, [eax]
        and     edx, 0x7F7F7F7F
        sub     edx, 0x01010101
        and     edx, 0x80808080
        jnz     @b
        add     eax, 4
        dec     ecx
        jnz     .multiple_byte_processing_loop
        pop     ecx
        and     ecx, 11b
        jz      @f

.single_byte_processing:
        cmp     ch, [eax]
        jz      @f
        dec     cl
        jz      .loc_a
        cmp     ch, [eax+1]
        jz      .loc_a
        dec     cl
        jz      .loc_b
        cmp     ch, [eax+2]
        jz      .loc_b
        add     eax, 3
    @@: sub     eax, [esp+_str]
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_a:
        sub     eax, [esp+_str]
        inc     eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_b:
        sub     eax, [esp+_str]
        add     eax, 2
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_strpbrk

_str = 4
_chr = 8

        mov     eax, [esp+_str]
        xor     ecx, ecx
        mov     edx, [esp+_chr]
        push    ecx ecx ecx ecx ecx ecx ecx ecx
    @@: mov     cl, [edx]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jcxz    @f
        else
        test    cx, cx
        jz      @f
        end if
        bts     [esp], ecx
        inc     edx
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        inc     eax
    @@: mov     cl, [eax]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jcxz    @f
        else
        test    cx, cx
        jz      @f
        end if
        bt      [esp], ecx
        jnb     .loop
        add     esp, 8 * 4
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     eax, ecx
        add     esp, 8 * 4
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_strrchr

_str = 4
_chr = 8

        mov     cl, [esp+_chr]
        mov     eax, [esp+_str]
        mov     edx, eax
    @@: cmp     byte [eax], 0
        jz      @f
        inc     eax
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        cmp     [eax], cl
        jz      @f
        cmp     eax, edx
        jz      .return_zero
        dec     eax
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_zero:
        xor     eax, eax
    @@:
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wcscat_s

_dst = 4
_num = 8
_src = 12

        push    esi
        xor     eax, eax
        mov     edx, [esp+4+_dst]
        test    edx, edx
        jz      .einval
        mov     ecx, [esp+4+_num]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .einval
        else
        test    ecx, ecx
        jz      .einval
        end if
        mov     esi, [esp+4+_src]
        test    esi, esi
        jz      .einval_clr_dst
    @@: cmp     [edx], ax
        jz      @f
        add     edx, 2
        dec     ecx
        jnz     @b
        mov     edx, [esp+4+_dst]

.einval_clr_dst:
        mov     [edx], ax

.einval:
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        call    [_errno]
        mov     dword [eax], EINVAL
        end if
        mov     eax, EINVAL
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     ax, [esi]
        add     esi, 2
        mov     [edx], ax
        add     edx, 2
        test    ax, ax
        jz      @f
        dec     ecx
        jnz     @b
        mov     edx, [esp+4+_dst]
        mov     [edx], cx
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        call    [_errno]
        mov     dword [eax], ERANGE
        end if
        mov     eax, ERANGE
    @@: pop     esi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wcscmp

_wcs1 = 4
_wcs2 = 8

        mov     edx, [esp+_wcs2]
        push    ebx
        movzx   ebx, word [edx]
        push    esi
        mov     esi, [esp+8+_wcs1]
        movzx   ecx, word [esi]
        sub     ecx, ebx
        jnz     @f
        sub     esi, edx
 .loop: test    bx, bx
        jz      @f
        add     edx, 2
        movzx   ebx, word [edx]
        movzx   ecx, word [esi+edx]
        sub     ecx, ebx
        jz      .loop
    @@: test    ecx, ecx
        jz      .epilog
        js      @f
        mov     ecx, 1

.epilog:
        mov     eax, ecx
        pop     esi ebx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        or      ecx, -1
        jmp     .epilog
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wcsncmp

_str1 = 4
_str2 = 8
_cnt = 12

        xor     eax, eax
        mov     ecx, [esp+_cnt]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .return
        else
        test    ecx, ecx
        jz      .return
        end if
        mov     edx, [esp+_str2]
        push    ebx
        mov     ebx, [esp+4+_str1]
        sub     ebx, edx
        jmp     @f

.general_loop:
        add     edx, 2
    @@: mov     ax, [ebx+edx]
        cmp     ax, [edx]
        jnz     @f
        test    ax, ax
        jz      @f
        dec     ecx
        jnz     .general_loop
    @@: movzx   ecx, word [edx]
        sub     eax, ecx
        pop     ebx

.return:
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

if defined PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET & PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET eq TRUE

proc c_wcscpy

_dst = 4
_src = 8

        push    esi
        mov     esi, [esp+4+_src]
        push    edi
        mov     edi, [esp+8+_dst]
        cld
    @@: lodsw
        stosw
        test    ax, ax
        jnz     @b
        pop     edi esi
        mov     eax, [esp+_dst]
        retn
endp

else

proc c_wcscpy

_dst = 4
_src = 8

        mov     eax, [esp+_dst]
        mov     edx, [esp+_src]
        sub     eax, edx
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        add     edx, 2
    @@: mov     cx, [edx]
        mov     [eax+edx], cx
        test    cx, cx
        jnz     .loop
        mov     eax, [esp+_dst]
        retn
endp

end if

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wcscpy_s

_dst = 4
_num = 8
_src = 12

        push    edi
        mov     edi, [esp+4+_dst]
        test    edi, edi
        jz      .einval
        mov     ecx, [esp+4+_num]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   .einval
        else
        test    ecx, ecx
        jz      .einval
        end if
        mov     edx, [esp+4+_src]
        test    edx, edx
        jz      .einval_clr_dst
        sub     edi, edx
        xor     eax, eax
    @@: mov     ax, [edx]
        mov     [edi+edx], ax
        test    ax, ax
        jz      @f
        add     edx, 2
        dec     ecx
        jnz     @b
        mov     edi, [esp+4+_dst]
        mov     [edi], cx
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        call    [_errno]
        mov     dword [eax], ERANGE
        end if
        mov     eax, ERANGE
    @@: pop     edi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.einval_clr_dst:
        mov     [edi], dx

.einval:
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        call    [_errno]
        mov     dword [eax], EINVAL
        end if
        mov     eax, EINVAL
        pop     edi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wcslen

_str = 4

        xor     ecx, ecx
        mov     eax, [esp+_str]
        cmp     [eax], cx
        jnz     .loop
        mov     eax, ecx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        add     eax, 2
        cmp     [eax], cx
        jnz     .loop
        sub     eax, [esp+_str]
        shr     eax, 1
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wcsnlen

_str = 4
_num = 8

        mov     ecx, [esp+_num]
        test    ecx, ecx
        jle     .return_zero
        xor     edx, edx
        mov     eax, [esp+_str]
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_zero:
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        add     eax, 2
        dec     ecx
        jz      .epilog
    @@: cmp     [eax], dx
        jnz     .loop

.epilog:
        sub     eax, [esp+_str]
        shr     eax, 1
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wcspbrk

_wcs = 4
_chr = 8

        push    edi
        mov     eax, [esp+4+_wcs]
        mov     cx, [eax]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jcxz    .return_zero
        else
        test    cx, cx
        jz      .return_zero
        end if
        mov     edi, [esp+4+_chr]
        push    esi
        mov     dx, [edi]
        test    dx, dx
        jnz     @f
        pop     esi

.return_zero:
        xor     eax, eax
        pop     edi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loop:
        mov     dx, [edi]
    @@: mov     esi, edi
    @@: cmp     dx, cx
        jz      @f
        add     esi, 2
        mov     dx, [esi]
        test    dx, dx
        jnz     @b
        add     eax, 2
        mov     cx, [eax]
        test    cx, cx
        jnz     .loop
        xor     eax, eax
    @@: pop     esi edi
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wcsrchr

_wcs = 4
_chr = 8

        mov     eax, [esp+_wcs]
        mov     edx, eax
    @@: mov     cx, [eax]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jcxz    @f
        else
        test    cx, cx
        jz      @f
        end if
        add     eax, 2
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     cx, [esp+_chr]
    @@: cmp     [eax], cx
        jz      @f
        cmp     eax, edx
        jz      .return_zero
        sub     eax, 2
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_zero:
        xor     eax, eax
    @@:
        retn
endp

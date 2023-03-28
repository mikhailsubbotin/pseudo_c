; Pseudo C / memory.asm
; ---------------------
; 06.06.2022 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_memccpy

_dst = 4
_src = 8
_chr = 12
_cnt = 16

        mov     eax, [esp+_cnt]
        test    eax, eax
        jz      .return
        mov     ecx, [esp+_src]
        mov     edx, [esp+_dst]
        sub     edx, ecx
        push    ebx
        mov     bh, byte [esp+4+_chr]
    @@: mov     bl, [ecx]
        mov     [ecx+edx], bl
        inc     ecx
        cmp     bl, bh
        jz      @f
        dec     eax
        jnz     @b
        pop     ebx

.return:
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        add     eax, edx
        pop     ebx
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

if defined PSEUDO_C_SSE2_INSTRUCTION_SET & PSEUDO_C_SSE2_INSTRUCTION_SET eq TRUE

proc c_memcmp

_ptr1 = 4
_ptr2 = 8
_cnt = 12

        mov     ecx, [esp+_cnt]
        push    esi edi
        mov     esi, [esp+8+_ptr1]
        add     esi, ecx
        mov     edi, [esp+8+_ptr2]
        add     edi, ecx
        neg     ecx
        jz      .loc_h
        mov     edx, 0xFFFF
        cmp     ecx, -16
        ja      .loc_b
.loc_a: movdqu  xmm1, [esi+ecx]
        movdqu  xmm2, [edi+ecx]
        pcmpeqb xmm1, xmm2
        pmovmskb eax, xmm1
        xor     eax, edx
        jnz     .loc_f
        add     ecx, 16
        jz      .loc_h
        cmp     ecx, -16
        jna     .loc_a
.loc_b: cmp     ecx, -8
        ja      .loc_c
        movq    xmm1, [esi+ecx]
        movq    xmm2, [edi+ecx]
        pcmpeqb xmm1, xmm2
        pmovmskb eax, xmm1
        xor     eax, edx
        jnz     .loc_f
        add     ecx, 8
        jz      .loc_h
.loc_c: cmp     ecx, -4
        ja      .loc_d
        movd    xmm1, [esi+ecx]
        movd    xmm2, [edi+ecx]
        pcmpeqb xmm1, xmm2
        pmovmskb eax, xmm1
        xor     eax, edx
        jnz     .loc_f
        add     ecx, 4
        jz      .loc_h
.loc_d: cmp     ecx, -2
        ja      .loc_e
        movzx   eax, word [esi+ecx]
        movzx   edx, word [edi+ecx]
        sub     eax, edx
        jnz     .loc_g
        add     ecx, 2
        jz      .loc_h
.loc_e: test    ecx, ecx
        jz      .loc_h
        movzx   eax, byte [esi+ecx]
        movzx   edx, byte [edi+ecx]
        sub     eax, edx
        pop     edi esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_f:
        bsf     eax, eax
        add     ecx, eax
        movzx   eax, byte [esi+ecx]
        movzx   edx, byte [edi+ecx]
        sub     eax, edx
        pop     edi esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_g:
        neg     al
        sbb     ecx, -1
        movzx   eax, byte [esi+ecx]
        movzx   edx, byte [edi+ecx]
        sub     eax, edx
        pop     edi esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_h:
        xor     eax, eax
        pop     edi esi
        retn
endp

else if defined PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET & PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET eq TRUE

proc c_memcmp

_ptr1 = 4
_ptr2 = 8
_cnt = 12

        mov     ecx, [esp+_cnt]
        push    edi esi
        mov     dl, cl
        mov     edi, [esp+8+_ptr2]
        mov     esi, [esp+8+_ptr1]
        shr     ecx, 2
        repz    cmpsd
        jnz     .pointers_fix
        mov     cl, dl
        and     cl, 11b
    @@: repz    cmpsb
        jz      .equal
        mov     dl, [esi-1]
        pop     esi
        sub     dl, [edi-1]
        movsx   eax, dl
        pop     edi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.pointers_fix:
        mov     ecx, 4
        sub     esi, ecx
        sub     edi, ecx
        jmp     @b

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.equal:
        xor     eax, eax
        pop     esi edi
        retn
endp

else

proc c_memcmp

_ptr1 = 4
_ptr2 = 8
_cnt = 12

        mov     ecx, [esp+_cnt]
        mov     eax, [esp+_ptr2]
        push    esi
        mov     esi, [esp+4+_ptr1]
        sub     esi, eax
        mov     edx, ecx
        shr     ecx, 2
        jz      .loc_x
    @@: mov     edx, [esi+eax]
        cmp     edx, [eax]
        jnz     .loc_b
        add     eax, 4
        dec     ecx
        jnz     @b
.loc_x: and     edx, 11b
        jnz     @f
        mov     eax, ecx
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_a:
        inc     eax
    @@: mov     cl, [esi+eax]
        sub     cl, [eax]
        jnz     @f
        dec     edx
        jnz     .loc_a
        mov     eax, edx
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        movsx   eax, cl
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_b:
        sub     dl, [eax]
        jnz     .loc_c
        sub     dh, [eax+1]
        jnz     @f
        shr     edx, 16
        sub     dl, [eax+2]
        jnz     .loc_c
        sub     dh, [eax+3]
    @@: movsx   eax, dh
        pop     esi
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_c:
        movsx   eax, dl
        pop     esi
        retn
endp

end if

align PSEUDO_C_INSTRUCTIONS_ALIGN

if defined PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET & PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET eq TRUE

proc c_memcpy

_dst = 4
_src = 8
_cnt = 12

        cld
        mov     ecx, [esp+_cnt]
        cmp     ecx, 8
        push    esi
        mov     esi, [esp+4+_src]
        push    edi
        mov     edi, [esp+8+_dst]
        jb      .loc_c
        bt      di, 0
        jnc     .loc_a
        movsb
        dec     ecx
.loc_a: bt      di, 1
        jnc     .loc_b
        movsw
        sub     ecx, 2
.loc_b: mov     dl, cl
        shr     ecx, 2
        rep     movsd
        mov     cl, dl
        and     cl, 11b
.loc_c: rep     movsb
        pop     edi esi
        mov     eax, [esp+_dst]
        retn
endp

else

proc c_memcpy

_dst = 4
_src = 8
_cnt = 12

        push    ebx
        mov     ebx, [esp+4+_src]
        mov     edx, [esp+4+_dst]
        sub     edx, ebx
        mov     ecx, [esp+4+_cnt]
        push    ecx
        shr     ecx, 2
        jz      .loc_b
.loc_a: mov     eax, [ebx]
        mov     [edx+ebx], eax
        add     ebx, 4
        dec     ecx
        jnz     .loc_a
.loc_b: pop     ecx
        and     ecx, 11b
        jz      .loc_d
.loc_c: mov     al, [ebx]
        mov     [edx+ebx], al
        inc     ebx
        dec     ecx
        jnz     .loc_c
.loc_d: mov     eax, [esp+4+_dst]
        pop     ebx
        retn
endp

end if

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_memcpy_mmx0

_dst = 4
_src = 8
_cnt = 12

        push    ebx
        mov     ebx, [esp+4+_src]
        mov     edx, [esp+4+_dst]
        sub     edx, ebx
        mov     ecx, [esp+4+_cnt]
        shr     ecx, 3
        mov     eax, ecx
        jnz     .8bcl
        and     ecx, 11b
        jnz     .1bcl
        mov     eax, [esp+4+_dst]
        pop     ebx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        add     ebx, 8
 .8bcl: movq    mm0, [ebx]
        movq    [edx+ebx], mm0
        dec     eax
        jnz     @b
        and     ecx, 11b
        jnz     .1bcl
        mov     eax, [esp+4+_dst]
        pop     ebx
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        inc     ebx
 .1bcl: mov     al, [ebx]
        mov     [edx+ebx], al
        dec     ecx
        jnz     @b
        mov     eax, [esp+4+_dst]
        pop     ebx
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

if defined PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET & PSEUDO_C_STRINGS_OPERATION_INSTRUCTION_SET eq TRUE

proc c_memset

_ptr = 4
_val = 8
_cnt = 12

        mov     ecx, [esp+_cnt]
        movzx   eax, byte [esp+_val]
        push    edi
        mov     edi, [esp+4+_ptr]
        cld
        cmp     ecx, 8
        jb      .loc_c
        mov     edx, 0x01010101
        mul     edx
        bt      di, 0
        jnc     .loc_a
        stosb
        dec     ecx
.loc_a: bt      di, 1
        jnc     .loc_b
        stosw
        sub     ecx, 2
.loc_b: mov     dl, cl
        shr     ecx, 2
        rep     stosd
        mov     cl, dl
        and     cl, 11b
.loc_c: rep     stosb
        pop     edi
        mov     eax, [esp+_ptr]
        retn
endp

else

proc c_memset

_ptr = 4
_val = 8
_cnt = 12

        movzx   eax, byte [esp+_val]
        mov     ecx, 0x01010101
        mul     ecx
        mov     ecx, [esp+_cnt]
        mov     edx, [esp+_ptr]
        cmp     ecx, 8
        jb      .loc_g
        bt      dx, 0
        jnc     .loc_a
        dec     ecx
        mov     [edx], ah
        inc     edx
.loc_a: bt      dx, 1
        jnc     .loc_b
        sub     ecx, 2
        mov     [edx], ax
        add     edx, 2
.loc_b: push    ecx
        shr     ecx, 2
        jz      .loc_d
.loc_c: mov     [edx], eax
        add     edx, 4
        dec     ecx
        jnz     .loc_c
.loc_d: pop     ecx
        and     ecx, 11b
        jz      .loc_f
.loc_e: mov     [edx], al
        inc     edx
        dec     ecx
        jnz     .loc_e
.loc_f: mov     eax, [esp+_ptr]
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.loc_g:
        test    cl, 111b
        jz      .loc_f
.loc_h: mov     [edx], ah
        inc     edx
        dec     ecx
        jnz     .loc_h
        mov     eax, [esp+_ptr]
        retn
endp

end if

; Pseudo C / heap.asm
; -------------------
; 22.09.2021 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ProcessHeapAlloc

_dwFlags = 4
_dwBytes = 8

        invoke  GetProcessHeap
        test    eax, eax
        jz      @f
        pop     ecx
        push    eax ecx
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        jmp     [HeapAlloc]
        else
        jmp     [RtlAllocateHeap]
        end if

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ProcessHeapFree

_lpMemory = 4

        invoke  GetProcessHeap
        test    eax, eax
        jz      .return_error_code
        push    dword [esp+_lpMemory] NULL eax
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        call    [HeapFree]
        else
        call    [RtlFreeHeap]
        end if
        test    eax, eax
        jz      .return_error_code
        xor     eax, eax
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  GetLastError
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ProcessHeapFreeEx

_dwFlags = 4
_lpMemory = 8

        invoke  GetProcessHeap
        test    eax, eax
        jz      .return_error_code
        push    dword [esp+_lpMemory] dword [esp+4+_dwFlags] eax
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        call    [HeapFree]
        else
        call    [RtlFreeHeap]
        end if
        test    eax, eax
        jz      .return_error_code
        xor     eax, eax
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  GetLastError
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ProcessHeapReAllocate

_dwFlags = 4
_lpMemory = 8
_dwBytes = 12

        invoke  GetProcessHeap
        test    eax, eax
        jz      @f
        mov     edx, [esp+_dwFlags]
        test    dl, HEAP_REALLOC_IN_PLACE_ONLY
        jnz     .error_not_enough_memory
        and     dl, HEAP_REALLOC_IN_PLACE_ONLY xor 0xFF
        mov     [esp+_dwFlags], eax ; hHeap
        push    dword [esp+_lpMemory]
        mov     [esp+4+_lpMemory], edx ; dwFlags
        push    NULL eax
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        call    [HeapFree]
        jmp     [HeapAlloc]
        else
        call    [RtlFreeHeap]
        jmp     [RtlAllocateHeap]
        end if

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_not_enough_memory:
        invoke  SetLastError, ERROR_NOT_ENOUGH_MEMORY
        xor     eax, eax
    @@:
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ProcessHeapSecuredFree

_lpMemory = 4

        invoke  GetProcessHeap
        test    eax, eax
        jz      .return_error_code
        push    esi
        mov     esi, [esp+4+_lpMemory]
        push    esi NULL eax
        push    esi NULL eax
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        call    [HeapSize]
        else
        call    [RtlSizeHeap]
        end if
        cmp     eax, -1
        jz      .restore_stack_and_return_error_code
        ccall   c_memset, esi, 0, eax
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        call    [HeapFree]
        else
        call    [RtlFreeHeap]
        end if
        test    eax, eax
        pop     esi
        jz      .return_error_code
        xor     eax, eax
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.restore_stack_and_return_error_code:
        add     esp, 12
        pop     esi

.return_error_code:
        invoke  GetLastError
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ProcessHeapSecuredFreeEx

_lpMemory = 4
_dwFlags = 8

        invoke  GetProcessHeap
        test    eax, eax
        jz      .return_error_code
        push    esi
        mov     esi, [esp+4+_lpMemory]
        push    esi dword [esp+4+4+_dwFlags] eax
        push    esi NULL eax
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        call    [HeapSize]
        else
        call    [RtlSizeHeap]
        end if
        cmp     eax, -1
        jz      .restore_stack_and_return_error_code
        ccall   c_memset, esi, 0, eax
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        call    [HeapFree]
        else
        call    [RtlFreeHeap]
        end if
        test    eax, eax
        pop     esi
        jz      .return_error_code
        xor     eax, eax
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.restore_stack_and_return_error_code:
        add     esp, 12
        pop     esi

.return_error_code:
        invoke  GetLastError
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ProcessHeapSize

_lpMemory = 4

        invoke  GetProcessHeap
        test    eax, eax
        jz      @f
        pop     ecx
        push    NULL eax ecx
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        jmp     [HeapSize]
        else
        jmp     [RtlSizeHeap]
        end if

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     eax, -1
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ProcessHeapSizeEx

_dwFlags = 4
_lpMemory = 8

        invoke  GetProcessHeap
        test    eax, eax
        jz      @f
        pop     ecx
        push    eax ecx
        if defined PSEUDO_C_COMPATIBILITY_WIN9X & PSEUDO_C_COMPATIBILITY_WIN9X eq TRUE
        jmp     [HeapSize]
        else
        jmp     [RtlSizeHeap]
        end if

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     eax, -1
        retn    8
endp

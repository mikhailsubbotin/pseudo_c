; Pseudo C / fs.asm
; -----------------
; 31.03.2023 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_mkdir

_path = 4

        invoke  CreateDirectoryA, dword [esp+4+_path], NULL
        test    eax, eax
        jz      .return_error_code
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  GetLastError
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        test    eax, eax
        jz      @f
        ccall   c_dosmaperr, eax
        mov     eax, -1
    @@: end if
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wmkdir

_path = 4

        invoke  CreateDirectoryW, dword [esp+4+_path], NULL
        test    eax, eax
        jz      .return_error_code
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  GetLastError
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        test    eax, eax
        jz      @f
        ccall   c_dosmaperr, eax
        mov     eax, -1
    @@: end if
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_remove

_file_path = 4

        invoke  DeleteFileA, dword [esp+_file_path]
        test    eax, eax
        jz      .return_error_code
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  GetLastError
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        test    eax, eax
        jz      @f
        ccall   c_dosmaperr, eax
        mov     eax, -1
    @@: end if
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_wremove

_file_path = 4

        invoke  DeleteFileW, dword [esp+_file_path]
        test    eax, eax
        jz      .return_error_code
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  GetLastError
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        test    eax, eax
        jz      @f
        ccall   c_dosmaperr, eax
        mov     eax, -1
    @@: end if
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc rmdir

_path = 4

        invoke  RemoveDirectoryA, dword [esp+_path]
        test    eax, eax
        jz      .return_error_code
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  GetLastError
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        test    eax, eax
        jz      @f
        ccall   c_dosmaperr, eax
        mov     eax, -1
    @@: end if
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc wrmdir

_path = 4

        invoke  RemoveDirectoryW, dword [esp+_path]
        test    eax, eax
        jz      .return_error_code
        xor     eax, eax
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_code:
        invoke  GetLastError
        if ~ defined PSEUDO_C_USE_ONLY_WINAPI | PSEUDO_C_USE_ONLY_WINAPI eq FALSE
        test    eax, eax
        jz      @f
        ccall   c_dosmaperr, eax
        mov     eax, -1
    @@: end if
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateDirectoryRecursivelyA

_pszPath = 4

        push    ebx
        mov     ebx, [esp+4+_pszPath]
        test    ebx, ebx
        jz      .invalid_parameter
        push    esi edi
        stdcall IsPathExistA, ebx
        test    eax, eax
        jnz     .return_success
        ccall   c_strlen, ebx
        test    eax, eax
        jz      .error_path_not_found
        add     eax, 1 + 1
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_memory_alloc
        mov     esi, eax
        mov     edi, eax
        sub     edi, ebx
        xor     ax, ax
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop:
        inc     ebx
    @@: mov     al, [ebx]
        test    al, al
        jz      .recursively_directory_creation_loop_write_slash
        mov     [edi+ebx], al
        cmp     al, '\'
        jz      .recursively_directory_creation_loop_is_subdirectory_exist
        cmp     al, '/'
        jz      .recursively_directory_creation_loop_write_slash
        or      ax, 1 shl 8
        jmp     .recursively_directory_creation_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop_write_slash:
        mov     byte [edi+ebx], '\'

.recursively_directory_creation_loop_is_subdirectory_exist:
        test    ax, 1 shl 8
        jz      .recursively_directory_creation_loop_next
        mov     byte [edi+ebx+1], 0
        stdcall IsPathExistA, esi
        test    eax, eax
        jnz     @f
        invoke  CreateDirectoryA, esi, eax
        test    eax, eax
        jz      .error_creating_directory
    @@: xor     ax, ax

.recursively_directory_creation_loop_next:
        cmp     byte [ebx], 0
        jnz     .recursively_directory_creation_loop
        stdcall ProcessHeapFree, esi

.return_success:
        xor     eax, eax

.restore_stack_and_return:
        pop     edi esi ebx
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.invalid_parameter:
        invoke  SetLastError, ERROR_INVALID_PARAMETER
        mov     eax, ERROR_INVALID_PARAMETER
        pop     ebx
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_path_not_found:
        invoke  SetLastError, ERROR_PATH_NOT_FOUND
        mov     eax, ERROR_PATH_NOT_FOUND
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_memory_alloc:
        invoke  GetLastError
        mov     esi, eax
        invoke  CreateDirectoryA, ebx, NULL
        test    eax, eax
        jnz     .return_success
        mov     eax, esi
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_creating_directory:
        invoke  GetLastError
        mov     ebx, eax
        stdcall ProcessHeapFree, esi
        mov     eax, ebx
        jmp     .restore_stack_and_return
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateDirectoryRecursivelyW

_pwcsPath = 4

        push    ebx
        mov     ebx, [esp+4+_pwcsPath]
        push    esi edi
        xor     eax, eax
        invoke  GetFullPathNameW, ebx, eax, eax, eax
        test    eax, eax
        jz      .error_unable_to_get_full_directory_path
        cmp     eax, 4
        jb      .alloc_path_buffer
        cmp     dword [ebx], '\' or ('\' shl 16)
        jnz     @f
        cmp     dword [ebx+4], '?' or ('\' shl 16)
        jnz     @f
        add     ebx, 8
        sub     eax, 4
    @@: cmp     eax, 2
        jb      .error_invalid_name

.alloc_path_buffer:
        mov     esi, eax
        add     eax, 4 + 1
        shl     eax, 1
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_path_buffer
        mov     ecx, esi
        mov     esi, eax
        cmp     ecx, MAX_PATH - 12 - 1
        jb      .get_full_directory_path
        mov     dword [eax], '\' or ('\' shl 16)
        mov     dword [eax+4], '?' or ('\' shl 16)
        add     eax, 8

.get_full_directory_path:
        mov     edi, eax
        mov     word [eax+ecx], 0
        invoke  GetFullPathNameW, ebx, ecx, eax, NULL
        test    eax, eax
        jz      .free_path_buffer_and_return_last_system_error_code
        xor     cl, cl
        jmp     .recursively_directory_creation_loop_without_increment_address

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop:
        add     edi, 2

.recursively_directory_creation_loop_without_increment_address:
        mov     ax, [edi]
        test    ax, ax
        jz      .recursively_directory_creation_loop_write_slash
        cmp     ax, '/'
        jz      .recursively_directory_creation_loop_write_slash
        cmp     ax, '\'
        jz      .recursively_directory_creation_loop_is_subdirectory_exist
        or      cl, 1
        jmp     .recursively_directory_creation_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop_write_slash:
        mov     word [edi], '\'

.recursively_directory_creation_loop_is_subdirectory_exist:
        add     edi, 2
        mov     bx, [edi]
        test    cl, cl
        jz      .recursively_directory_creation_loop_next
        mov     word [edi], 0
        stdcall IsPathExistW, esi
        test    eax, eax
        jnz     @f
        invoke  CreateDirectoryW, esi, eax
        test    eax, eax
        jz      .free_path_buffer_and_return_last_system_error_code
    @@: mov     [edi], bx
        xor     cl, cl

.recursively_directory_creation_loop_next:
        test    bx, bx
        jnz     .recursively_directory_creation_loop_without_increment_address
        stdcall ProcessHeapFree, esi

.return_success:
        xor     eax, eax

.restore_stack_and_return:
        pop     edi esi ebx
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_get_full_directory_path:
        invoke  GetLastError
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_invalid_name:
        invoke  SetLastError, ERROR_INVALID_NAME
        mov     eax, ERROR_INVALID_NAME
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_path_buffer:
        invoke  GetLastError
        mov     esi, eax
        invoke  CreateDirectoryW, ebx, NULL
        test    eax, eax
        jnz     .return_success
        mov     eax, esi
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.free_path_buffer_and_return_last_system_error_code:
        invoke  GetLastError
        mov     ebx, eax
        stdcall ProcessHeapFree, esi
        mov     eax, ebx
        jmp     .restore_stack_and_return
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateFileBackupA

_lpExistingFileName = 4
_lpNewFileName = 8

        mov     eax, [esp+_lpNewFileName]
        test    eax, eax
        jz      .new_destination_path_based_on_source_path
        cmp     byte [eax], 0
        jz      .new_destination_path_based_on_source_path
        invoke  CopyFileA, dword [esp+8+_lpExistingFileName], eax, FALSE
        test    eax, eax
        jz      @f
        xor     eax, eax
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        invoke  GetLastError
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.new_destination_path_based_on_source_path:
        mov     eax, [esp+_lpExistingFileName]
        test    eax, eax
        jz      .error_path_not_found
        cmp     byte [eax], 0
        jz      .error_path_not_found
        push    ebx
        stdcall c_strlen, eax
        add     eax, .sizeof.extension_backup + 1
        push    eax
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_path_buffer_memory
        mov     ebx, eax
        stdcall c_strcpy_s, eax
        test    eax, eax
        jnz     .error_unable_to_copy_string
        mov     eax, .extension_backup
        mov     [esp+8], eax
        call    c_strcat_s
        add     esp, 12
        test    eax, eax
        jnz     .error_unable_to_concatenate_string
        invoke  CopyFileA, dword [esp+8+4+_lpExistingFileName], ebx, eax
        test    eax, eax
        jz      .error_unable_to_copy_file
        stdcall ProcessHeapFree, ebx
        xor     eax, eax

.restore_stack_and_return:
        pop     ebx
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_path_not_found:
        invoke  SetLastError, ERROR_PATH_NOT_FOUND
        mov     eax, ERROR_PATH_NOT_FOUND
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_path_buffer_memory:
        add     esp, 8
        invoke  GetLastError
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_copy_string:
        add     esp, 12

.error_unable_to_concatenate_string:
        cmp     eax, ERANGE
        jz      .error_insufficient_buffer
        stdcall ProcessHeapFree, ebx
        invoke  SetLastError, ERROR_INVALID_PARAMETER
        mov     eax, ERROR_INVALID_PARAMETER
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_insufficient_buffer:
        stdcall ProcessHeapFree, ebx
        invoke  SetLastError, ERROR_INSUFFICIENT_BUFFER
        mov     eax, ERROR_INSUFFICIENT_BUFFER
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_copy_file:
        invoke  GetLastError
        push    ebx
        mov     ebx, eax
        call    ProcessHeapFree
        mov     eax, ebx
        jmp     .restore_stack_and_return

align PSEUDO_C_INSTRUCTIONS_ALIGN

.extension_backup db '.bak', 0
.sizeof.extension_backup = $ - .extension_backup - 1

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateFileBackupW

_lpExistingFileName = 4
_lpNewFileName = 8

        mov     eax, [esp+_lpNewFileName]
        test    eax, eax
        jz      .new_destination_path_based_on_source_path
        cmp     word [eax], 0
        jz      .new_destination_path_based_on_source_path
        invoke  CopyFileW, dword [esp+8+_lpExistingFileName], eax, FALSE
        test    eax, eax
        jz      @f
        xor     eax, eax
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        invoke  GetLastError
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.new_destination_path_based_on_source_path:
        mov     eax, [esp+_lpExistingFileName]
        test    eax, eax
        jz      .error_path_not_found
        cmp     word [eax], 0
        jz      .error_path_not_found
        push    ebx
        stdcall c_wcslen, eax
        add     eax, .sizeof.extension_backup + 1
        push    eax
        shl     eax, 1
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_path_buffer_memory
        mov     ebx, eax
        stdcall c_wcscpy_s, eax
        test    eax, eax
        jnz     .error_unable_to_copy_string
        mov     eax, .extension_backup
        mov     [esp+8], eax
        call    c_wcscat_s
        add     esp, 12
        test    eax, eax
        jnz     .error_unable_to_concatenate_string
        invoke  CopyFileW, dword [esp+8+4+_lpExistingFileName], ebx, eax
        test    eax, eax
        jz      .error_unable_to_copy_file
        stdcall ProcessHeapFree, ebx
        xor     eax, eax

.restore_stack_and_return:
        pop     ebx
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_path_not_found:
        invoke  SetLastError, ERROR_PATH_NOT_FOUND
        mov     eax, ERROR_PATH_NOT_FOUND
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_path_buffer_memory:
        add     esp, 8
        invoke  GetLastError
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_copy_string:
        add     esp, 12

.error_unable_to_concatenate_string:
        cmp     eax, ERANGE
        jz      .error_insufficient_buffer
        stdcall ProcessHeapFree, ebx
        invoke  SetLastError, ERROR_INVALID_PARAMETER
        mov     eax, ERROR_INVALID_PARAMETER
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_insufficient_buffer:
        stdcall ProcessHeapFree, ebx
        invoke  SetLastError, ERROR_INSUFFICIENT_BUFFER
        mov     eax, ERROR_INSUFFICIENT_BUFFER
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_copy_file:
        invoke  GetLastError
        push    ebx
        mov     ebx, eax
        call    ProcessHeapFree
        mov     eax, ebx
        jmp     .restore_stack_and_return

align PSEUDO_C_INSTRUCTIONS_ALIGN

.extension_backup du '.bak', 0
.sizeof.extension_backup = ($ - .extension_backup) / 2 - 1

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateFileBackupExA

_lpExistingFileName = 4
_lpNewFileName = 8
_bNumerate = 12

        mov     eax, [esp+_lpNewFileName]
        push    ebp
        movzx   ebp, byte [esp+4+_bNumerate]
        and     ebp, 1
        jz      .is_simple_copy
        test    eax, eax
        jz      .source_file_path_base
        cmp     byte [eax], 0
        jnz     @f

.source_file_path_base:
        mov     eax, [esp+4+_lpExistingFileName]
        test    eax, eax
        jz      .error_path_not_found
        cmp     byte [eax], 0
        jz      .error_path_not_found
    @@: push    ebx esi edi
        stdcall c_strlen, eax
        mov     ebx, eax
        add     eax, .sizeof.extension_backup + 1 + 10 + 1
        push    eax
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        pop     ecx edi
        jz      .restore_registers_and_return
        mov     esi, eax
        stdcall c_strcpy_s, eax, ecx, edi
        test    eax, eax
        jnz     .error_unable_to_copy_string
        cmp     edi, [esp+12+16+_lpNewFileName]
        jz      @f
        mov     eax, .extension_backup
        mov     [esp+8], eax
        call    c_strcat_s
        test    eax, eax
        jnz     .error_unable_to_concatenate_string
        call    c_strlen
        mov     ebx, eax
    @@: add     esp, 12
        lea     ebx, [ebx+esi+1]
        mov     edi, 1
    @@: invoke  CopyFileA, dword [esp+8+16+_lpExistingFileName], esi, ebp
        test    eax, eax
        jnz     @f
        invoke  GetLastError
        cmp     eax, ERROR_FILE_EXISTS
        jnz     .error_unable_to_copy_file
        mov     byte [ebx-1], '.'
        ccall   c_ultoa, edi, ebx, 10
        inc     edi
        jnz     @b

.error_insufficient_buffer:
        mov     ebx, ERROR_INSUFFICIENT_BUFFER
        jmp     .free_path_buffer_memory_and_set_last_error_code

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        stdcall ProcessHeapFree, esi
        mov     eax, edi

.restore_registers_and_return:
        pop     edi esi ebx

.restore_ebp_and_return:
        pop     ebp
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.is_simple_copy:
        test    eax, eax
        jz      .source_file_path_base
        cmp     byte [eax], 0
        jz      .source_file_path_base
        invoke  CopyFileA, dword [esp+8+4+_lpExistingFileName], eax, ebp
        test    eax, eax
        jz      .restore_ebp_and_return
        mov     eax, 1
        jmp     .restore_ebp_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_path_not_found:
        invoke  SetLastError, ERROR_PATH_NOT_FOUND
        xor     eax, eax
        jmp     .restore_ebp_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_copy_string:
.error_unable_to_concatenate_string:
        add     esp, 12
        cmp     eax, ERANGE
        jz      .error_insufficient_buffer
        mov     ebx, ERROR_INVALID_PARAMETER

.free_path_buffer_memory_and_set_last_error_code:
        stdcall ProcessHeapFree, esi
        invoke  SetLastError, ebx
        xor     eax, eax
        jmp     .restore_registers_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_copy_file:
        mov     ebx, eax
        jmp     .free_path_buffer_memory_and_set_last_error_code

align PSEUDO_C_INSTRUCTIONS_ALIGN

.extension_backup db '.bak', 0
.sizeof.extension_backup = $ - .extension_backup - 1

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateFileBackupExW

_lpExistingFileName = 4
_lpNewFileName = 8
_bNumerate = 12

        mov     eax, [esp+_lpNewFileName]
        push    ebp
        movzx   ebp, byte [esp+4+_bNumerate]
        and     ebp, 1
        jz      .is_simple_copy
        test    eax, eax
        jz      .source_file_path_base
        cmp     word [eax], 0
        jnz     @f

.source_file_path_base:
        mov     eax, [esp+4+_lpExistingFileName]
        test    eax, eax
        jz      .error_path_not_found
        cmp     word [eax], 0
        jz      .error_path_not_found
    @@: push    ebx esi edi
        stdcall c_wcslen, eax
        mov     ebx, eax
        add     eax, .sizeof.extension_backup + 1 + 10 + 1
        push    eax
        shl     eax, 1
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        pop     ecx edi
        jz      .restore_registers_and_return
        mov     esi, eax
        stdcall c_wcscpy_s, eax, ecx, edi
        test    eax, eax
        jnz     .error_unable_to_copy_string
        cmp     edi, [esp+12+16+_lpNewFileName]
        jz      @f
        mov     eax, .extension_backup
        mov     [esp+8], eax
        call    c_wcscat_s
        test    eax, eax
        jnz     .error_unable_to_concatenate_string
        call    c_wcslen
        mov     ebx, eax
    @@: add     esp, 12
        shl     ebx, 1
        lea     ebx, [ebx+esi+2]
        mov     edi, 1
    @@: invoke  CopyFileW, dword [esp+8+16+_lpExistingFileName], esi, ebp
        test    eax, eax
        jnz     @f
        invoke  GetLastError
        cmp     eax, ERROR_FILE_EXISTS
        jnz     .error_unable_to_copy_file
        mov     word [ebx-2], '.'
        ccall   c_ultow, edi, ebx, 10
        inc     edi
        jnz     @b

.error_insufficient_buffer:
        mov     ebx, ERROR_INSUFFICIENT_BUFFER
        jmp     .free_path_buffer_memory_and_set_last_error_code

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        stdcall ProcessHeapFree, esi
        mov     eax, edi

.restore_registers_and_return:
        pop     edi esi ebx

.restore_ebp_and_return:
        pop     ebp
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.is_simple_copy:
        test    eax, eax
        jz      .source_file_path_base
        cmp     word [eax], 0
        jz      .source_file_path_base
        invoke  CopyFileW, dword [esp+8+4+_lpExistingFileName], eax, ebp
        test    eax, eax
        jz      .restore_ebp_and_return
        mov     eax, 1
        jmp     .restore_ebp_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_path_not_found:
        invoke  SetLastError, ERROR_PATH_NOT_FOUND
        xor     eax, eax
        jmp     .restore_ebp_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_copy_string:
.error_unable_to_concatenate_string:
        add     esp, 12
        cmp     eax, ERANGE
        jz      .error_insufficient_buffer
        mov     ebx, ERROR_INVALID_PARAMETER

.free_path_buffer_memory_and_set_last_error_code:
        stdcall ProcessHeapFree, esi
        invoke  SetLastError, ebx
        xor     eax, eax
        jmp     .restore_registers_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_copy_file:
        mov     ebx, eax
        jmp     .free_path_buffer_memory_and_set_last_error_code

align PSEUDO_C_INSTRUCTIONS_ALIGN

.extension_backup du '.bak', 0
.sizeof.extension_backup = ($ - .extension_backup) / 2 - 1

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc IsPathExistA

_pszPath = 4

        push    ebx
        invoke  SetErrorMode, SEM_FAILCRITICALERRORS
        push    eax ; for SetErrorMode
        invoke  GetFileAttributesA, dword [esp+4+4+_pszPath]
        cmp     eax, INVALID_FILE_ATTRIBUTES
        setnz   bl
        call    [SetErrorMode]
        movzx   eax, bl
        pop     ebx
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc IsPathExistW

_pwcsPath = 4

        push    ebx
        invoke  SetErrorMode, SEM_FAILCRITICALERRORS
        push    eax ; for SetErrorMode
        invoke  GetFileAttributesW, dword [esp+4+4+_pwcsPath]
        cmp     eax, INVALID_FILE_ATTRIBUTES
        setnz   bl
        call    [SetErrorMode]
        movzx   eax, bl
        pop     ebx
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc NewFileA

_lpFileName = 4
_dwDesiredAccess = 8
_dwShareMode = 12
_bCreateAlways = 16
_dwFlagsAndAttributes = 20

        push    ebp ebx
        mov     ebx, [esp+8+_lpFileName]
        push    esi edi
        xor     eax, eax
        invoke  GetFullPathNameA, ebx, eax, eax, eax
        test    eax, eax
        jz      .return_invalid_handle_value
        mov     esi, eax
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_path_buffer
        mov     ebp, eax
        mov     edi, eax
        invoke  GetFullPathNameA, ebx, esi, eax, NULL
        test    eax, eax
        jz      .push_current_last_system_error
        xor     si, si
        xor     ah, ah
        jmp     .recursively_directory_creation_loop_without_increment_address

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop:
        inc     edi

.recursively_directory_creation_loop_without_increment_address:
        mov     al, [edi]
        test    al, al
        jz      .file_creation
        cmp     al, '/'
        jz      .recursively_directory_creation_loop_write_slash
        cmp     al, '\'
        jz      .recursively_directory_creation_loop_is_subdirectory_exist
        or      ah, 1
        jmp     .recursively_directory_creation_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop_write_slash:
        mov     byte [edi], '\'

.recursively_directory_creation_loop_is_subdirectory_exist:
        inc     edi
        mov     bl, [edi]
        test    ah, ah
        jz      .recursively_directory_creation_loop_next
        mov     byte [edi], 0
        stdcall IsPathExistA, ebp
        test    eax, eax
        jnz     @f
        invoke  CreateDirectoryA, ebp, eax
        test    eax, eax
        jz      .pre_push_current_last_system_error_and_delete_created_subfolders
        inc     si
    @@: mov     [edi], bl
        xor     ah, ah

.recursively_directory_creation_loop_next:
        test    bl, bl
        jnz     .recursively_directory_creation_loop_without_increment_address
        xor     ebx, ebx
        jmp     .free_path_buffer_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.file_creation:
        movzx   eax, byte [esp+16+_bCreateAlways]
        and     al, 1b
        inc     al
        invoke  CreateFileA, ebp, dword [esp+20+16+_dwDesiredAccess], dword [esp+16+16+_dwShareMode], NULL, eax, dword [esp+4+16+_dwFlagsAndAttributes], NULL
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .push_current_last_system_error_and_delete_created_subfolders
        mov     ebx, eax

.free_path_buffer_and_return:
        stdcall ProcessHeapFree, ebp
        mov     eax, ebx

.restore_stack_and_return:
        pop     edi esi ebx ebp
        retn    20

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_invalid_handle_value:
        mov     eax, INVALID_HANDLE_VALUE
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_path_buffer:
        invoke  GetLastError
        mov     esi, eax
        movzx   eax, byte [esp+16+_bCreateAlways]
        and     al, 1b
        inc     al
        invoke  CreateFileA, dword [esp+24+16+_lpFileName], dword [esp+20+16+_dwDesiredAccess], dword [esp+16+16+_dwShareMode], NULL, eax, dword [esp+4+16+_dwFlagsAndAttributes], NULL
        cmp     eax, INVALID_HANDLE_VALUE
        jnz     .restore_stack_and_return
        invoke  SetLastError, esi
        jmp     .return_invalid_handle_value

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.push_current_last_system_error:
        invoke  GetLastError
        push    eax
        stdcall ProcessHeapFree, ebp
        call    [SetLastError]
        jmp     .return_invalid_handle_value

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.pre_push_current_last_system_error_and_delete_created_subfolders:
        mov     byte [edi-1], 0

.push_current_last_system_error_and_delete_created_subfolders:
        invoke  GetLastError
        mov     edi, eax
        test    si, si
        jz      .free_path_buffer_and_return_invalid_handle_value

.recursively_directory_removing_loop:
        ccall   c_strrchr, ebp, dword '\'
        test    eax, eax
        jz      .free_path_buffer_and_return_invalid_handle_value
        mov     byte [eax], 0
        invoke  RemoveDirectoryA, ebp
        test    eax, eax
        jnz     @f
        invoke  GetLastError
        cmp     eax, ERROR_FILE_NOT_FOUND
        jnz     .free_path_buffer_and_return_invalid_handle_value
    @@: dec     si
        jnz     .recursively_directory_removing_loop

.free_path_buffer_and_return_invalid_handle_value:
        stdcall ProcessHeapFree, ebp
        invoke  SetLastError, edi
        jmp     .return_invalid_handle_value
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc NewFileW

_lpFileName = 4
_dwDesiredAccess = 8
_dwShareMode = 12
_bCreateAlways = 16
_dwFlagsAndAttributes = 20

        push    ebp ebx
        mov     ebx, [esp+8+_lpFileName]
        push    esi edi
        xor     eax, eax
        invoke  GetFullPathNameW, ebx, eax, eax, eax
        test    eax, eax
        jz      .return_invalid_handle_value
        cmp     eax, 4
        jb      .alloc_path_buffer
        cmp     dword [ebx], '\' or ('\' shl 16)
        jnz     .alloc_path_buffer
        cmp     dword [ebx+4], '?' or ('\' shl 16)
        jnz     .alloc_path_buffer
        add     ebx, 8
        sub     eax, 4
        cmp     eax, 2
        jb      .error_invalid_name

.alloc_path_buffer:
        mov     esi, eax
        cmp     eax, MAX_PATH - 12 - 1
        jb      @f
        add     eax, 4
    @@: shl     eax, 1
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_path_buffer
        mov     ebp, eax
        cmp     esi, MAX_PATH - 12 - 1
        jb      .get_full_file_path
        mov     dword [eax], '\' or ('\' shl 16)
        mov     dword [eax+4], '?' or ('\' shl 16)
        add     eax, 8

.get_full_file_path:
        mov     edi, eax
        invoke  GetFullPathNameW, ebx, esi, eax, NULL
        test    eax, eax
        jz      .push_current_last_system_error
        xor     si, si
        xor     cl, cl
        jmp     .recursively_directory_creation_loop_without_increment_address

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop:
        add     edi, 2

.recursively_directory_creation_loop_without_increment_address:
        mov     ax, [edi]
        test    ax, ax
        jz      .file_creation
        cmp     ax, '/'
        jz      .recursively_directory_creation_loop_write_slash
        cmp     ax, '\'
        jz      .recursively_directory_creation_loop_is_subdirectory_exist
        or      cl, 1
        jmp     .recursively_directory_creation_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop_write_slash:
        mov     word [edi], '\'

.recursively_directory_creation_loop_is_subdirectory_exist:
        add     edi, 2
        mov     bx, [edi]
        test    cl, cl
        jz      .recursively_directory_creation_loop_next
        mov     word [edi], 0
        stdcall IsPathExistW, ebp
        test    eax, eax
        jnz     @f
        invoke  CreateDirectoryW, ebp, eax
        test    eax, eax
        jz      .pre_push_current_last_system_error_and_delete_created_subfolders
        inc     si
    @@: mov     [edi], bx
        xor     cl, cl

.recursively_directory_creation_loop_next:
        test    bx, bx
        jnz     .recursively_directory_creation_loop_without_increment_address
        xor     ebx, ebx
        jmp     .free_path_buffer_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.file_creation:
        movzx   eax, byte [esp+16+_bCreateAlways]
        and     al, 1b
        inc     al
        invoke  CreateFileW, ebp, dword [esp+20+16+_dwDesiredAccess], dword [esp+16+16+_dwShareMode], NULL, eax, dword [esp+4+16+_dwFlagsAndAttributes], NULL
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .push_current_last_system_error_and_delete_created_subfolders
        mov     ebx, eax

.free_path_buffer_and_return:
        stdcall ProcessHeapFree, ebp
        mov     eax, ebx

.restore_stack_and_return:
        pop     edi esi ebx ebp
        retn    20

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_invalid_name:
        invoke  SetLastError, ERROR_INVALID_NAME

.return_invalid_handle_value:
        mov     eax, INVALID_HANDLE_VALUE
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_path_buffer:
        invoke  GetLastError
        mov     esi, eax
        movzx   eax, byte [esp+16+_bCreateAlways]
        and     al, 1b
        inc     al
        invoke  CreateFileW, dword [esp+24+16+_lpFileName], dword [esp+20+16+_dwDesiredAccess], dword [esp+16+16+_dwShareMode], NULL, eax, dword [esp+4+16+_dwFlagsAndAttributes], NULL
        cmp     eax, INVALID_HANDLE_VALUE
        jnz     .restore_stack_and_return
        invoke  SetLastError, esi
        jmp     .return_invalid_handle_value

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.push_current_last_system_error:
        invoke  GetLastError
        push    eax
        stdcall ProcessHeapFree, ebp
        call    [SetLastError]
        jmp     .return_invalid_handle_value

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.pre_push_current_last_system_error_and_delete_created_subfolders:
        mov     word [edi-2], 0

.push_current_last_system_error_and_delete_created_subfolders:
        invoke  GetLastError
        mov     edi, eax
        test    si, si
        jz      .free_path_buffer_and_return_invalid_handle_value

.recursively_directory_removing_loop:
        ccall   c_wcsrchr, ebp, dword '\'
        test    eax, eax
        jz      .free_path_buffer_and_return_invalid_handle_value
        mov     word [eax], 0
        invoke  RemoveDirectoryW, ebp
        test    eax, eax
        jnz     @f
        invoke  GetLastError
        cmp     eax, ERROR_FILE_NOT_FOUND
        jnz     .free_path_buffer_and_return_invalid_handle_value
    @@: dec     si
        jnz     .recursively_directory_removing_loop

.free_path_buffer_and_return_invalid_handle_value:
        stdcall ProcessHeapFree, ebp
        invoke  SetLastError, edi
        jmp     .return_invalid_handle_value
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc NewFileExA

_lpFileName = 4
_dwDesiredAccess = 8
_dwShareMode = 12
_lpSecurityAttributes = 16
_bCreateAlways = 20
_dwFlagsAndAttributes = 24
_hTemplateFile = 28

        push    ebp ebx
        mov     ebx, [esp+8+_lpFileName]
        push    esi edi
        xor     eax, eax
        invoke  GetFullPathNameA, ebx, eax, eax, eax
        test    eax, eax
        jz      .return_invalid_handle_value
        mov     esi, eax
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_path_buffer
        mov     ebp, eax
        mov     edi, eax
        invoke  GetFullPathNameA, ebx, esi, eax, NULL
        test    eax, eax
        jz      .push_current_last_system_error
        xor     si, si
        xor     ah, ah
        jmp     .recursively_directory_creation_loop_without_increment_address

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop:
        inc     edi

.recursively_directory_creation_loop_without_increment_address:
        mov     al, [edi]
        test    al, al
        jz      .file_creation
        cmp     al, '/'
        jz      .recursively_directory_creation_loop_write_slash
        cmp     al, '\'
        jz      .recursively_directory_creation_loop_is_subdirectory_exist
        or      ah, 1
        jmp     .recursively_directory_creation_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop_write_slash:
        mov     byte [edi], '\'

.recursively_directory_creation_loop_is_subdirectory_exist:
        inc     edi
        mov     bl, [edi]
        test    ah, ah
        jz      .recursively_directory_creation_loop_next
        mov     byte [edi], 0
        stdcall IsPathExistA, ebp
        test    eax, eax
        jnz     @f
        invoke  CreateDirectoryA, ebp, eax
        test    eax, eax
        jz      .pre_push_current_last_system_error_and_delete_created_subfolders
        inc     si
    @@: mov     [edi], bl
        xor     ah, ah

.recursively_directory_creation_loop_next:
        test    bl, bl
        jnz     .recursively_directory_creation_loop_without_increment_address
        xor     ebx, ebx
        jmp     .free_path_buffer_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.file_creation:
        movzx   eax, byte [esp+16+_bCreateAlways]
        and     al, 1b
        inc     al
        invoke  CreateFileA, ebp, dword [esp+20+16+_dwDesiredAccess], dword [esp+16+16+_dwShareMode], dword [esp+12+16+_lpSecurityAttributes], eax, dword [esp+4+16+_dwFlagsAndAttributes], dword [esp+16+_hTemplateFile]
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .push_current_last_system_error_and_delete_created_subfolders
        mov     ebx, eax

.free_path_buffer_and_return:
        stdcall ProcessHeapFree, ebp
        mov     eax, ebx

.restore_stack_and_return:
        pop     edi esi ebx ebp
        retn    28

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_invalid_handle_value:
        mov     eax, INVALID_HANDLE_VALUE
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_path_buffer:
        invoke  GetLastError
        mov     esi, eax
        movzx   eax, byte [esp+16+_bCreateAlways]
        and     al, 1b
        inc     al
        invoke  CreateFileA, dword [esp+24+16+_lpFileName], dword [esp+20+16+_dwDesiredAccess], dword [esp+16+16+_dwShareMode], dword [esp+12+16+_lpSecurityAttributes], eax, dword [esp+4+16+_dwFlagsAndAttributes], dword [esp+16+_hTemplateFile]
        cmp     eax, INVALID_HANDLE_VALUE
        jnz     .restore_stack_and_return
        invoke  SetLastError, esi
        jmp     .return_invalid_handle_value

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.push_current_last_system_error:
        invoke  GetLastError
        push    eax
        stdcall ProcessHeapFree, ebp
        call    [SetLastError]
        jmp     .return_invalid_handle_value

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.pre_push_current_last_system_error_and_delete_created_subfolders:
        mov     byte [edi-1], 0

.push_current_last_system_error_and_delete_created_subfolders:
        invoke  GetLastError
        mov     edi, eax
        test    si, si
        jz      .free_path_buffer_and_return_invalid_handle_value

.recursively_directory_removing_loop:
        ccall   c_strrchr, ebp, dword '\'
        test    eax, eax
        jz      .free_path_buffer_and_return_invalid_handle_value
        mov     byte [eax], 0
        invoke  RemoveDirectoryA, ebp
        test    eax, eax
        jnz     @f
        invoke  GetLastError
        cmp     eax, ERROR_FILE_NOT_FOUND
        jnz     .free_path_buffer_and_return_invalid_handle_value
    @@: dec     si
        jnz     .recursively_directory_removing_loop

.free_path_buffer_and_return_invalid_handle_value:
        stdcall ProcessHeapFree, ebp
        invoke  SetLastError, edi
        jmp     .return_invalid_handle_value
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc NewFileExW

_lpFileName = 4
_dwDesiredAccess = 8
_dwShareMode = 12
_lpSecurityAttributes = 16
_bCreateAlways = 20
_dwFlagsAndAttributes = 24
_hTemplateFile = 28

        push    ebp ebx
        mov     ebx, [esp+8+_lpFileName]
        push    esi edi
        xor     eax, eax
        invoke  GetFullPathNameW, ebx, eax, eax, eax
        test    eax, eax
        jz      .return_invalid_handle_value
        cmp     eax, 4
        jb      .alloc_path_buffer
        cmp     dword [ebx], '\' or ('\' shl 16)
        jnz     .alloc_path_buffer
        cmp     dword [ebx+4], '?' or ('\' shl 16)
        jnz     .alloc_path_buffer
        add     ebx, 8
        sub     eax, 4
        cmp     eax, 2
        jb      .error_invalid_name

.alloc_path_buffer:
        mov     esi, eax
        cmp     eax, MAX_PATH - 12 - 1
        jb      @f
        add     eax, 4
    @@: shl     eax, 1
        stdcall ProcessHeapAlloc, NULL, eax
        test    eax, eax
        jz      .error_unable_to_alloc_path_buffer
        mov     ebp, eax
        cmp     esi, MAX_PATH - 12 - 1
        jb      .get_full_file_path
        mov     dword [eax], '\' or ('\' shl 16)
        mov     dword [eax+4], '?' or ('\' shl 16)
        add     eax, 8

.get_full_file_path:
        mov     edi, eax
        invoke  GetFullPathNameW, ebx, esi, eax, NULL
        test    eax, eax
        jz      .push_current_last_system_error
        xor     si, si
        xor     cl, cl
        jmp     .recursively_directory_creation_loop_without_increment_address

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop:
        add     edi, 2

.recursively_directory_creation_loop_without_increment_address:
        mov     ax, [edi]
        test    ax, ax
        jz      .file_creation
        cmp     ax, '/'
        jz      .recursively_directory_creation_loop_write_slash
        cmp     ax, '\'
        jz      .recursively_directory_creation_loop_is_subdirectory_exist
        or      cl, 1
        jmp     .recursively_directory_creation_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.recursively_directory_creation_loop_write_slash:
        mov     word [edi], '\'

.recursively_directory_creation_loop_is_subdirectory_exist:
        add     edi, 2
        mov     bx, [edi]
        test    cl, cl
        jz      .recursively_directory_creation_loop_next
        mov     word [edi], 0
        stdcall IsPathExistW, ebp
        test    eax, eax
        jnz     @f
        invoke  CreateDirectoryW, ebp, eax
        test    eax, eax
        jz      .pre_push_current_last_system_error_and_delete_created_subfolders
        inc     si
    @@: mov     [edi], bx
        xor     cl, cl

.recursively_directory_creation_loop_next:
        test    bx, bx
        jnz     .recursively_directory_creation_loop_without_increment_address
        xor     ebx, ebx
        jmp     .free_path_buffer_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.file_creation:
        movzx   eax, byte [esp+16+_bCreateAlways]
        and     al, 1b
        inc     al
        invoke  CreateFileW, ebp, dword [esp+20+16+_dwDesiredAccess], dword [esp+16+16+_dwShareMode], dword [esp+12+16+_lpSecurityAttributes], eax, dword [esp+4+16+_dwFlagsAndAttributes], dword [esp+16+_hTemplateFile]
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .push_current_last_system_error_and_delete_created_subfolders
        mov     ebx, eax

.free_path_buffer_and_return:
        stdcall ProcessHeapFree, ebp
        mov     eax, ebx

.restore_stack_and_return:
        pop     edi esi ebx ebp
        retn    20

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_invalid_name:
        invoke  SetLastError, ERROR_INVALID_NAME

.return_invalid_handle_value:
        mov     eax, INVALID_HANDLE_VALUE
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_unable_to_alloc_path_buffer:
        invoke  GetLastError
        mov     esi, eax
        movzx   eax, byte [esp+16+_bCreateAlways]
        and     al, 1b
        inc     al
        invoke  CreateFileW, dword [esp+24+16+_lpFileName], dword [esp+20+16+_dwDesiredAccess], dword [esp+16+16+_dwShareMode], dword [esp+12+16+_lpSecurityAttributes], eax, dword [esp+4+16+_dwFlagsAndAttributes], dword [esp+16+_hTemplateFile]
        cmp     eax, INVALID_HANDLE_VALUE
        jnz     .restore_stack_and_return
        invoke  SetLastError, esi
        jmp     .return_invalid_handle_value

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.push_current_last_system_error:
        invoke  GetLastError
        push    eax
        stdcall ProcessHeapFree, ebp
        call    [SetLastError]
        jmp     .return_invalid_handle_value

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.pre_push_current_last_system_error_and_delete_created_subfolders:
        mov     word [edi-2], 0

.push_current_last_system_error_and_delete_created_subfolders:
        invoke  GetLastError
        mov     edi, eax
        test    si, si
        jz      .free_path_buffer_and_return_invalid_handle_value

.recursively_directory_removing_loop:
        ccall   c_wcsrchr, ebp, dword '\'
        test    eax, eax
        jz      .free_path_buffer_and_return_invalid_handle_value
        mov     word [eax], 0
        invoke  RemoveDirectoryW, ebp
        test    eax, eax
        jnz     @f
        invoke  GetLastError
        cmp     eax, ERROR_FILE_NOT_FOUND
        jnz     .free_path_buffer_and_return_invalid_handle_value
    @@: dec     si
        jnz     .recursively_directory_removing_loop

.free_path_buffer_and_return_invalid_handle_value:
        stdcall ProcessHeapFree, ebp
        invoke  SetLastError, edi
        jmp     .return_invalid_handle_value
endp

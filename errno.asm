; Pseudo C / dosmap.asm
; ---------------------
; 11.05.2020 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc errtable
.oscode:
dd ERROR_INVALID_FUNCTION
.errnocode: dd EINVAL
dd ERROR_FILE_NOT_FOUND, ENOENT
dd ERROR_PATH_NOT_FOUND, ENOENT
dd ERROR_TOO_MANY_OPEN_FILES, EMFILE
dd ERROR_ACCESS_DENIED, EACCES
dd ERROR_INVALID_HANDLE, EBADF
dd ERROR_ARENA_TRASHED, ENOMEM
dd ERROR_NOT_ENOUGH_MEMORY, ENOMEM
dd ERROR_INVALID_BLOCK, ENOMEM
dd ERROR_BAD_ENVIRONMENT, E2BIG
dd ERROR_BAD_FORMAT, ENOEXEC
dd ERROR_INVALID_ACCESS, EINVAL
dd ERROR_INVALID_DATA, EINVAL
dd ERROR_INVALID_DRIVE, ENOENT
dd ERROR_CURRENT_DIRECTORY, EACCES
dd ERROR_NOT_SAME_DEVICE, EXDEV
dd ERROR_NO_MORE_FILES, ENOENT
dd ERROR_LOCK_VIOLATION, EACCES
dd ERROR_BAD_NETPATH, ENOENT
dd ERROR_NETWORK_ACCESS_DENIED, EACCES
dd ERROR_BAD_NET_NAME, ENOENT
dd ERROR_FILE_EXISTS, EEXIST
dd ERROR_CANNOT_MAKE, EACCES
dd ERROR_FAIL_I24, EACCES
dd ERROR_INVALID_PARAMETER, EINVAL
dd ERROR_NO_PROC_SLOTS, EAGAIN
dd ERROR_DRIVE_LOCKED, EACCES
dd ERROR_BROKEN_PIPE, EPIPE
dd ERROR_DISK_FULL, ENOSPC
dd ERROR_INVALID_TARGET_HANDLE, EBADF
dd ERROR_INVALID_HANDLE, EINVAL
dd ERROR_WAIT_NO_CHILDREN, ECHILD
dd ERROR_CHILD_NOT_COMPLETE, ECHILD
dd ERROR_DIRECT_ACCESS_HANDLE, EBADF
dd ERROR_NEGATIVE_SEEK, EINVAL
dd ERROR_SEEK_ON_DEVICE, EACCES
dd ERROR_DIR_NOT_EMPTY, ENOTEMPTY
dd ERROR_NOT_LOCKED, EACCES
dd ERROR_BAD_PATHNAME, ENOENT
dd ERROR_MAX_THRDS_REACHED, EAGAIN
dd ERROR_LOCK_FAILED, EACCES
dd ERROR_ALREADY_EXISTS, EEXIST
dd ERROR_FILENAME_EXCED_RANGE, ENOENT
dd ERROR_NESTING_NOT_ALLOWED, EAGAIN
dd ERROR_NOT_ENOUGH_QUOTA, ENOMEM
sizeof.errtable equ ($ - errtable) / 8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_get_errno_from_oserr

_oserrno = 4

        mov     ecx, [esp+_oserrno]
        mov     eax, sizeof.errtable
    @@: dec     eax
        js      @f
        cmp     ecx, [errtable.oscode+eax*8]
        jnz     @b
        mov     eax, [errtable.errnocode+eax*8]
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        sub     ecx, ERROR_WRITE_PROTECT
        cmp     ecx, ERROR_SHARING_BUFFER_EXCEEDED - ERROR_WRITE_PROTECT
        ja      @f
        mov     eax, EACCES
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        lea     eax, [ecx-(ERROR_INVALID_STARTING_CODESEG-ERROR_WRITE_PROTECT)]
        mov     ecx, ERROR_INFLOOP_IN_RELOC_CHAIN - ERROR_INVALID_STARTING_CODESEG
        cmp     ecx, eax
        sbb     eax, eax
        and     eax, ecx
        add     eax, 8
        retn
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc c_dosmaperr

_oserrno = 4

        call    [__doserrno]
        mov     ecx, [esp+4+_oserrno]
        mov     [eax], ecx
        stdcall c_get_errno_from_oserr, ecx
        mov     [esp], eax
        call    [_errno]
        pop     ecx
        mov     [eax], ecx
        retn
endp

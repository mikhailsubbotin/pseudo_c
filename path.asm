; Pseudo C / path.asm
; -------------------
; 31.03.2023 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetCurrentModuleDirectoryA

_buf = 4
_len = 8

        push    edi
        mov     edi, [esp+4+_buf]
        invoke  GetModuleFilePathA, NULL, edi, dword [esp+4+_len]
        cmp     eax, [esp+4+_len]
        ja      .restore_stack_and_return
        jz      .insufficient_buffer_prepare
        dec     edi
    @@: cmp     byte [edi+eax], '\'
        jz      @f
        dec     eax
        jnz     @b
    @@: inc     eax
        mov     byte [edi+eax], 0

.restore_stack_and_return:
        pop     edi
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.insufficient_buffer_prepare:
        test    eax, eax
        jz      .restore_stack_and_return
        dec     edi
    @@: cmp     byte [edi+eax], '\'
        jz      @f
        dec     eax
        jnz     @b
    @@: inc     eax
        mov     byte [edi+eax], 0
        mov     eax, [esp+4+_len]
        jmp     .restore_stack_and_return
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetCurrentModuleDirectoryW

_buf = 4
_len = 8

        push    edi
        mov     edi, [esp+4+_buf]
        invoke  GetModuleFilePathW, NULL, edi, dword [esp+4+_len]
        cmp     eax, [esp+4+_len]
        ja      .restore_stack_and_return
        jz      .insufficient_buffer_prepare
        sub     edi, 2
    @@: cmp     word [edi+eax*2], '\'
        jz      @f
        dec     eax
        jnz     @b
    @@: inc     eax
        mov     word [edi+eax*2], 0

.restore_stack_and_return:
        pop     edi
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.insufficient_buffer_prepare:
        test    eax, eax
        jz      .restore_stack_and_return
        sub     edi, 2
    @@: cmp     word [edi+eax*2], '\'
        jz      @f
        dec     eax
        jnz     @b
    @@: inc     eax
        mov     word [edi+eax*2], 0
        mov     eax, [esp+4+_len]
        jmp     .restore_stack_and_return
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetLastNameFromPathA

_path = 4

        mov     eax, [esp+_path]
        mov     ecx, eax

.general_loop:
        mov     dl, [ecx]
        test    dl, dl
        jz      .epilog
        inc     ecx
        cmp     dl, '/'
        jz      .consecutive_slashes_skipping_loop
        cmp     dl, '\'
        jnz     .general_loop

.consecutive_slashes_skipping_loop:
        mov     dl, [ecx]
        test    dl, dl
        jz      .epilog
        cmp     dl, '/'
        jz      @f
        cmp     dl, '\'
        jnz     .save_position
    @@: inc     ecx
        jmp     .consecutive_slashes_skipping_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.save_position:
        mov     eax, ecx
        inc     ecx
        jmp     .general_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.epilog:
        sub     ecx, eax
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetLastNameFromPathW

_path = 4

        mov     eax, [esp+_path]
        mov     ecx, eax

.general_loop:
        mov     dx, [ecx]
        test    dx, dx
        jz      .epilog
        add     ecx, 2
        cmp     dx, '/'
        jz      .consecutive_slashes_skipping_loop
        cmp     dx, '\'
        jnz     .general_loop

.consecutive_slashes_skipping_loop:
        mov     dx, [ecx]
        test    dx, dx
        jz      .epilog
        cmp     dx, '/'
        jz      @f
        cmp     dx, '\'
        jnz     .save_position
    @@: add     ecx, 2
        jmp     .consecutive_slashes_skipping_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.save_position:
        mov     eax, ecx
        add     ecx, 2
        jmp     .general_loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.epilog:
        sub     ecx, eax
        shr     ecx, 1
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetFileNameFromPathA

_path = 4

        mov     eax, [esp+_path]
        mov     ecx, eax
 .loop: mov     dl, [ecx]
        test    dl, dl
        jz      .epilog
    @@: inc     ecx
        cmp     dl, '/'
        jz      .save_position
        cmp     dl, '\'
        jnz     .loop

.save_position:
        mov     eax, ecx
        mov     dl, [eax]
        test    dl, dl
        jnz     @b

.epilog:
        sub     ecx, eax
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetFileNameFromPathW

_path = 4

        mov     eax, [esp+_path]
        mov     ecx, eax
 .loop: mov     dx, [ecx]
        test    dx, dx
        jz      .epilog
    @@: add     ecx, 2
        cmp     dx, '/'
        jz      .save_position
        cmp     dx, '\'
        jnz     .loop

.save_position:
        mov     eax, ecx
        mov     dx, [eax]
        test    dx, dx
        jnz     @b

.epilog:
        sub     ecx, eax
        shr     ecx, 1
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetModuleFilePathA

_hModule = 4
_lpFilePath = 8
_nSize = 12

        invoke  GetModuleFileNameA, dword [esp+8+_hModule], dword [esp+4+_lpFilePath], dword [esp+_nSize]
        cmp     eax, [esp+_nSize]
        jz      .error_insufficient_buffer
        test    eax, eax
        jz      .return_error
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        pop     ecx

.return_error:
        or      eax, -1

.return:
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_insufficient_buffer:
        push    eax
        invoke  GetLastError
        cmp     eax, ERROR_INSUFFICIENT_BUFFER
        jz      @f
        test    eax, eax
        jnz     @b
        invoke  SetLastError, ERROR_INSUFFICIENT_BUFFER
    @@: pop     eax
        test    eax, eax
        jz      .return
        mov     edx, [esp+_lpFilePath]
        mov     byte [eax+edx-1], 0
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetModuleFilePathW

_hModule = 4
_lpFilePath = 8
_nSize = 12

        invoke  GetModuleFileNameW, dword [esp+8+_hModule], dword [esp+4+_lpFilePath], dword [esp+_nSize]
        cmp     eax, [esp+_nSize]
        jz      .error_insufficient_buffer
        test    eax, eax
        jz      .return_error
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        pop     ecx

.return_error:
        or      eax, -1

.return:
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_insufficient_buffer:
        push    eax
        invoke  GetLastError
        cmp     eax, ERROR_INSUFFICIENT_BUFFER
        jz      @f
        test    eax, eax
        jnz     @b
        invoke  SetLastError, ERROR_INSUFFICIENT_BUFFER
    @@: pop     eax
        test    eax, eax
        jz      .return
        lea     ecx, [eax+eax-2]
        mov     edx, [esp+_lpFilePath]
        mov     word [edx+ecx], 0
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetSpecialNtSystemFolderLocationA

_fid = 4
_len = 8
_buf = 12

__stack_length = 3 * 4

__registry_key_data_length = 0
__registry_key_data_type = 4
__registry_key_handle = 8

        push    ebx
        mov     ebx, [esp+4+_fid]
        test    ebx, ebx
        js      .return_error_invalid_folder_id
        cmp     ebx, SSFID_MY_VIDEO
        ja      .return_error_invalid_folder_id
        sub     esp, __stack_length
        mov     dword [esp+__registry_key_handle], 0
        cmp     ebx, SSFID_SYSTEM_ROOT
        ja      .shell_folders
        jz      .current_version_nt
        call    IsWow64
        mov     edx, KEY_READ
        test    eax, eax
        jz      @f
        or      edx, KEY_WOW64_64KEY
    @@: lea     ecx, [esp+__registry_key_handle]
        push    eax
        invoke  RegOpenKeyExA, HKEY_LOCAL_MACHINE, .current_version_registry_key, NULL, edx, ecx
        test    eax, eax
        pop     ecx
        jnz     .return_system_error_code
        mov     ecx, [.ddTable8664+ecx*4]
        mov     eax, [ebx+ecx*4]
        mov     ecx, [esp+__stack_length+4+_len]
        mov     [esp+__registry_key_data_length], ecx
        lea     ecx, [esp+__registry_key_data_type]
        invoke  RegQueryValueExA, dword [esp+20+__registry_key_handle], eax, NULL, ecx, dword [esp+4+__stack_length+4+_buf], esp
        cmp     eax, ERROR_MORE_DATA
        jz      .error_used_buffer_is_too_small
        test    eax, eax
        jnz     .return_system_error_code
        cmp     dword [esp+__registry_key_data_type], REG_SZ
        jnz     .error_invalid_type_of_registry_value

.close_registry_key:
        invoke  RegCloseKey, dword [esp+__registry_key_handle]
        invoke  SetLastError, ERROR_SUCCESS
        mov     eax, [esp+__registry_key_data_length]

.restore_registers_and_stack:
        add     esp, __stack_length

.restore_registers:
        pop     ebx
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_invalid_folder_id:
        invoke  SetLastError, ERROR_INVALID_PARAMETER
        mov     eax, -1
        jmp     .restore_registers

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.current_version_nt:
        lea     eax, [esp+__registry_key_handle]
        push    eax KEY_READ NULL .current_version_nt_registry_key HKEY_LOCAL_MACHINE
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.shell_folders:
        lea     eax, [esp+__registry_key_handle]
        push    eax KEY_READ NULL .shell_folders_registry_key HKEY_CURRENT_USER
    @@: call    [RegOpenKeyExA]
        test    eax, eax
        jnz     .return_system_error_code
        mov     eax, [esp+__stack_length+4+_len]
        mov     [esp+__registry_key_data_length], eax
        lea     ecx, [esp+__registry_key_data_type]
        mov     eax, [.ddTable86+ebx*4]
        invoke  RegQueryValueExA, dword [esp+20+__registry_key_handle], eax, NULL, ecx, dword [esp+4+__stack_length+4+_buf], esp
        cmp     eax, ERROR_MORE_DATA
        jz      .error_used_buffer_is_too_small
        test    eax, eax
        jnz     .return_system_error_code
        cmp     dword [esp+__registry_key_data_type], REG_SZ
        jz      .close_registry_key

.error_invalid_type_of_registry_value:
        invoke  SetLastError, ERROR_INVALID_DATA
        mov     eax, -1
        jmp     .restore_registers_and_stack

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_system_error_code:
        mov     ebx, eax
        mov     eax, [esp+__registry_key_handle]
        test    eax, eax
        jz      @f
        invoke  RegCloseKey, eax
    @@: invoke  SetLastError, ebx
        mov     eax, -1
        jmp     .restore_registers_and_stack

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_used_buffer_is_too_small:
        invoke  RegCloseKey, dword [esp+__registry_key_handle]
        invoke  SetLastError, ERROR_MORE_DATA
        mov     ecx, [esp+__registry_key_data_length]
        mov     eax, -1
        jmp     .restore_registers_and_stack

align PSEUDO_C_INSTRUCTIONS_ALIGN

.ddTable8664 dd .ddTable86
             dd .ddTable64

.ddTable86 dd .program_files_registry_key
           dd .program_files_registry_key
           dd .common_files_registry_key
           dd .common_files_registry_key
           ; -------------------------------
           dd .system_root_registry_key
           ; -------------------------------
           dd .application_data_registry_key
           dd .cd_burning_registry_key
           dd .desktop_registry_key
           dd .personal_registry_key
           dd .favorites_registry_key
           dd .fonts_registry_key
           dd .cache_registry_key
           dd .cookies_registry_key
           dd .history_registry_key
           dd .local_appdata_registry_key
           dd .my_music_registry_key
           dd .my_pictures_registry_key
           dd .my_video_registry_key

.ddTable64 dd .program_files_registry_key
           dd .program_files_x86_registry_key
           dd .common_files_registry_key
           dd .common_files_x86_registry_key

.current_version_registry_key db 'SOFTWARE\Microsoft\Windows\CurrentVersion', 0
align 4
.program_files_registry_key db 'ProgramFilesDir', 0
align 4
.program_files_x86_registry_key db 'ProgramFilesDir (x86)', 0
align 4
.common_files_registry_key db 'CommonFilesDir', 0
align 4
.common_files_x86_registry_key db 'CommonFilesDir (x86)', 0

align 4

.current_version_nt_registry_key db 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 0
align 4
.system_root_registry_key db 'SystemRoot', 0

align 4

.shell_folders_registry_key db 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 0
align 4
.application_data_registry_key db 'AppData', 0
align 4
.cache_registry_key db 'Cache', 0
align 4
.cookies_registry_key db 'Cookies', 0
align 4
.cd_burning_registry_key db 'CD Burning', 0
align 4
.desktop_registry_key db 'Desktop', 0
align 4
.favorites_registry_key db 'Favorites', 0
align 4
.fonts_registry_key db 'Fonts', 0
align 4
.history_registry_key db 'History', 0
align 4
.local_appdata_registry_key db 'Local AppData', 0
align 4
.my_music_registry_key db 'My Music', 0
align 4
.my_pictures_registry_key db 'My Pictures', 0
align 4
.my_video_registry_key db 'My Video', 0
align 4
.personal_registry_key db 'Personal', 0

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetSpecialNtSystemFolderLocationW

_fid = 4
_len = 8
_buf = 12

__stack_length = 3 * 4

__registry_key_data_length = 0
__registry_key_data_type = 4
__registry_key_handle = 8

        push    ebx
        mov     ebx, [esp+4+_fid]
        test    ebx, ebx
        js      .return_error_invalid_folder_id
        cmp     ebx, SSFID_MY_VIDEO
        ja      .return_error_invalid_folder_id
        sub     esp, __stack_length
        mov     dword [esp+__registry_key_handle], 0
        cmp     ebx, SSFID_SYSTEM_ROOT
        ja      .shell_folders
        jz      .current_version_nt
        call    IsWow64
        mov     edx, KEY_READ
        test    eax, eax
        jz      @f
        or      edx, KEY_WOW64_64KEY
    @@: lea     ecx, [esp+__registry_key_handle]
        push    eax
        invoke  RegOpenKeyExW, HKEY_LOCAL_MACHINE, .current_version_registry_key, NULL, edx, ecx
        test    eax, eax
        pop     ecx
        jnz     .return_system_error_code
        mov     ecx, [.ddTable8664+ecx*4]
        mov     eax, [ebx+ecx*4]
        mov     ecx, [esp+__stack_length+4+_len]
        shl     ecx, 1
        mov     [esp+__registry_key_data_length], ecx
        lea     ecx, [esp+__registry_key_data_type]
        invoke  RegQueryValueExW, dword [esp+20+__registry_key_handle], eax, NULL, ecx, dword [esp+4+__stack_length+4+_buf], esp
        cmp     eax, ERROR_MORE_DATA
        jz      .error_used_buffer_is_too_small
        test    eax, eax
        jnz     .return_system_error_code
        cmp     dword [esp+__registry_key_data_type], REG_SZ
        jnz     .error_invalid_type_of_registry_value

.close_registry_key:
        invoke  RegCloseKey, dword [esp+__registry_key_handle]
        invoke  SetLastError, ERROR_SUCCESS
        mov     eax, [esp+__registry_key_data_length]
        shr     eax, 1

.restore_registers_and_stack:
        add     esp, __stack_length

.restore_registers:
        pop     ebx
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_error_invalid_folder_id:
        invoke  SetLastError, ERROR_INVALID_PARAMETER
        mov     eax, -1
        jmp     .restore_registers

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.current_version_nt:
        lea     eax, [esp+__registry_key_handle]
        push    eax KEY_READ NULL .current_version_nt_registry_key HKEY_LOCAL_MACHINE
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.shell_folders:
        lea     eax, [esp+__registry_key_handle]
        push    eax KEY_READ NULL .shell_folders_registry_key HKEY_CURRENT_USER
    @@: call    [RegOpenKeyExW]
        test    eax, eax
        jnz     .return_system_error_code
        mov     eax, [esp+__stack_length+4+_len]
        shl     eax, 1
        mov     [esp+__registry_key_data_length], eax
        lea     ecx, [esp+__registry_key_data_type]
        mov     eax, [.ddTable86+ebx*4]
        invoke  RegQueryValueExW, dword [esp+20+__registry_key_handle], eax, NULL, ecx, dword [esp+4+__stack_length+4+_buf], esp
        cmp     eax, ERROR_MORE_DATA
        jz      .error_used_buffer_is_too_small
        test    eax, eax
        jnz     .return_system_error_code
        cmp     dword [esp+__registry_key_data_type], REG_SZ
        jz      .close_registry_key

.error_invalid_type_of_registry_value:
        invoke  SetLastError, ERROR_INVALID_DATA
        mov     eax, -1
        jmp     .restore_registers_and_stack

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_system_error_code:
        mov     ebx, eax
        mov     eax, [esp+__registry_key_handle]
        test    eax, eax
        jz      @f
        invoke  RegCloseKey, eax
    @@: invoke  SetLastError, ebx
        mov     eax, -1
        jmp     .restore_registers_and_stack

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_used_buffer_is_too_small:
        invoke  RegCloseKey, dword [esp+__registry_key_handle]
        invoke  SetLastError, ERROR_MORE_DATA
        mov     ecx, [esp+__registry_key_data_length]
        mov     eax, -1
        jmp     .restore_registers_and_stack

align PSEUDO_C_INSTRUCTIONS_ALIGN

.ddTable8664 dd .ddTable86
             dd .ddTable64

.ddTable86 dd .program_files_registry_key
           dd .program_files_registry_key
           dd .common_files_registry_key
           dd .common_files_registry_key
           ; -------------------------------
           dd .system_root_registry_key
           ; -------------------------------
           dd .application_data_registry_key
           dd .cd_burning_registry_key
           dd .desktop_registry_key
           dd .personal_registry_key
           dd .favorites_registry_key
           dd .fonts_registry_key
           dd .cache_registry_key
           dd .cookies_registry_key
           dd .history_registry_key
           dd .local_appdata_registry_key
           dd .my_music_registry_key
           dd .my_pictures_registry_key
           dd .my_video_registry_key

.ddTable64 dd .program_files_registry_key
           dd .program_files_x86_registry_key
           dd .common_files_registry_key
           dd .common_files_x86_registry_key

.current_version_registry_key du 'SOFTWARE\Microsoft\Windows\CurrentVersion', 0
align 4
.program_files_registry_key du 'ProgramFilesDir', 0
align 4
.program_files_x86_registry_key du 'ProgramFilesDir (x86)', 0
align 4
.common_files_registry_key du 'CommonFilesDir', 0
align 4
.common_files_x86_registry_key du 'CommonFilesDir (x86)', 0

align 4

.current_version_nt_registry_key du 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 0
align 4
.system_root_registry_key du 'SystemRoot', 0

align 4

.shell_folders_registry_key du 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 0
align 4
.application_data_registry_key du 'AppData', 0
align 4
.cache_registry_key du 'Cache', 0
align 4
.cookies_registry_key du 'Cookies', 0
align 4
.cd_burning_registry_key du 'CD Burning', 0
align 4
.desktop_registry_key du 'Desktop', 0
align 4
.favorites_registry_key du 'Favorites', 0
align 4
.fonts_registry_key du 'Fonts', 0
align 4
.history_registry_key du 'History', 0
align 4
.local_appdata_registry_key du 'Local AppData', 0
align 4
.my_music_registry_key du 'My Music', 0
align 4
.my_pictures_registry_key du 'My Pictures', 0
align 4
.my_video_registry_key du 'My Video', 0
align 4
.personal_registry_key du 'Personal', 0

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ReplaceFilePathExtensionA

_buf = 4
_len = 8
_ext = 12

        mov     edx, [esp+_buf]
        mov     ecx, [esp+_len]
        test    ecx, ecx
        jz      .return_zero
        add     ecx, edx
        push    esi
        xor     esi, esi
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_zero:
        mov     eax, ecx
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.reset:
        xor     esi, esi
 .loop: inc     edx
        cmp     edx, ecx
        jz      .more_data
    @@: mov     al, [edx]
        test    al, al
        jz      @f
        cmp     al, '\'
        jz      .reset
        cmp     al, '/'
        jz      .reset
        cmp     al, '.'
        jnz     .loop
        mov     esi, edx
        jmp     .loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        test    esi, esi
        jnz     @f
        mov     esi, edx
    @@: mov     edx, [esp+4+_ext]
        sub     edx, esi
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.write:
        inc     esi
        cmp     esi, ecx
        jz      .insufficient_buffer
    @@: mov     al, [esi+edx]
        mov     [esi], al
        test    al, al
        jnz     .write
        mov     eax, esi
        sub     eax, [esp+4+_buf]
        shr     eax, 1

.restore_stack_and_return:
        pop     esi
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.more_data:
        push    ERROR_MORE_DATA
    @@: call    [SetLastError]
        mov     eax, [esp+4+_len]
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.insufficient_buffer:
        mov     byte [ecx-1], 0
        push    ERROR_INSUFFICIENT_BUFFER
        jmp     @b
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc ReplaceFilePathExtensionW

_buf = 4
_len = 8
_ext = 12

        mov     edx, [esp+_buf]
        mov     ecx, [esp+_len]
        test    ecx, ecx
        jz      .return_zero
        shl     ecx, 1
        add     ecx, edx
        push    esi
        xor     esi, esi
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_zero:
        mov     eax, ecx
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.reset:
        xor     esi, esi
 .loop: add     edx, 2
        cmp     edx, ecx
        jz      .more_data
    @@: mov     ax, [edx]
        test    ax, ax
        jz      @f
        cmp     ax, '\'
        jz      .reset
        cmp     ax, '/'
        jz      .reset
        cmp     ax, '.'
        jnz     .loop
        mov     esi, edx
        jmp     .loop

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        test    esi, esi
        jnz     @f
        mov     esi, edx
    @@: mov     edx, [esp+4+_ext]
        sub     edx, esi
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
.write:
        add     esi, 2
        cmp     esi, ecx
        jz      .insufficient_buffer
    @@: mov     ax, [esi+edx]
        mov     [esi], ax
        test    ax, ax
        jnz     .write
        mov     eax, esi
        sub     eax, [esp+4+_buf]
        shr     eax, 1

.restore_stack_and_return:
        pop     esi
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.more_data:
        push    ERROR_MORE_DATA
    @@: call    [SetLastError]
        mov     eax, [esp+4+_len]
        jmp     .restore_stack_and_return

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.insufficient_buffer:
        mov     word [ecx-2], 0
        push    ERROR_INSUFFICIENT_BUFFER
        jmp     @b
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc WriteDirectoryPathEndingSlashA

_lpszDirectoryPath = 4
_nLength = 8

        mov     eax, [esp+_lpszDirectoryPath]
        mov     ecx, [esp+_nLength]
        cmp     ecx, 2
        jnb     @f

.error_insufficient_buffer:
        push    ERROR_INSUFFICIENT_BUFFER

.set_last_system_error_code_and_return_zero:
        call    [SetLastError]
        xor     eax, eax
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.path_string_length_loop:
        inc     eax
    @@: cmp     byte [eax], 0
        jz      @f
        dec     ecx
        jnz     .path_string_length_loop
        push    ERROR_MORE_DATA
        jmp     .set_last_system_error_code_and_return_zero

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     dl, [eax-1]
        cmp     dl, '/'
        jz      @f
        cmp     dl, '\'
        jz      @f
        cmp     ecx, 2
        jb      .error_insufficient_buffer
        mov     word [eax], '\'
        inc     eax
    @@: sub     eax, [esp+_lpszDirectoryPath]
        retn    8
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc WriteDirectoryPathEndingSlashW

_lpszDirectoryPath = 4
_nLength = 8

        mov     eax, [esp+_lpszDirectoryPath]
        mov     ecx, [esp+_nLength]
        cmp     ecx, 2
        jnb     @f

.error_insufficient_buffer:
        push    ERROR_INSUFFICIENT_BUFFER

.set_last_system_error_code_and_return_zero:
        call    [SetLastError]
        xor     eax, eax
        retn    8

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.path_string_length_loop:
        add     eax, 2
    @@: cmp     word [eax], 0
        jz      @f
        dec     ecx
        jnz     .path_string_length_loop
        push    ERROR_MORE_DATA
        jmp     .set_last_system_error_code_and_return_zero

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     dx, [eax-2]
        cmp     dx, '/'
        jz      @f
        cmp     dx, '\'
        jz      @f
        cmp     ecx, 2
        jb      .error_insufficient_buffer
        mov     dword [eax], '\'
        add     eax, 2
    @@: sub     eax, [esp+_lpszDirectoryPath]
        shr     eax, 1
        retn    8
endp

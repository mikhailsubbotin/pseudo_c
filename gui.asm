; Pseudo C / gui.asm
; ------------------
; 24.04.2023 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateButtonA

_lpszText = 4
_dwStyle = 8
_hFont = 12
_nPosX = 16
_nPosY = 20
_nWidth = 24
_nHeight = 28
_hMenu = 32
_hWndParent = 36

        invoke  GetWindowLongA, dword [esp+4+_hWndParent], GWL_HINSTANCE
        test    eax, eax
        jz      .return
        xor     ecx, ecx
        invoke  CreateWindowExA, ecx, .szButtonClassName, dword [esp+36+_lpszText], dword [esp+32+_dwStyle], dword [esp+28+_nPosX], dword [esp+24+_nPosY], dword [esp+20+_nWidth], dword [esp+16+_nHeight], dword [esp+12+_hWndParent], dword [esp+8+_hMenu], eax, ecx
        test    eax, eax
        jz      .return
        push    eax
        mov     eax, [esp+4+_hFont]
        test    eax, eax
        jnz     @f
        invoke  GetStockObject, DEFAULT_GUI_FONT
    @@: invoke  SendMessageA, dword [esp+12], WM_SETFONT, eax, FALSE
        pop     eax

.return:
        retn    36

align PSEUDO_C_INSTRUCTIONS_ALIGN

.szButtonClassName db 'BUTTON', 0

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateButtonW

_lpszText = 4
_dwStyle = 8
_hFont = 12
_nPosX = 16
_nPosY = 20
_nWidth = 24
_nHeight = 28
_hMenu = 32
_hWndParent = 36

        invoke  GetWindowLongW, dword [esp+4+_hWndParent], GWL_HINSTANCE
        test    eax, eax
        jz      .return
        xor     ecx, ecx
        invoke  CreateWindowExW, ecx, .szButtonClassName, dword [esp+36+_lpszText], dword [esp+32+_dwStyle], dword [esp+28+_nPosX], dword [esp+24+_nPosY], dword [esp+20+_nWidth], dword [esp+16+_nHeight], dword [esp+12+_hWndParent], dword [esp+8+_hMenu], eax, ecx
        test    eax, eax
        jz      .return
        push    eax
        mov     eax, [esp+4+_hFont]
        test    eax, eax
        jnz     @f
        invoke  GetStockObject, DEFAULT_GUI_FONT
    @@: invoke  SendMessageW, dword [esp+12], WM_SETFONT, eax, FALSE
        pop     eax

.return:
        retn    36

align PSEUDO_C_INSTRUCTIONS_ALIGN

.szButtonClassName du 'BUTTON', 0

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateSimpleToolTipA

_hWndParent = 4
_hTool = 8
_lpszText = 12

        invoke  GetWindowLongA, dword [esp+4+_hWndParent], GWL_HINSTANCE
        test    eax, eax
        jz      .return
        mov     ecx, [esp+_hTool]
        test    ecx, ecx
        jz      .error_invalid_window_handle
        cmp     ecx, INVALID_HANDLE_VALUE
        jz      .error_invalid_window_handle
        mov     edx, [esp+_lpszText]
        sub     esp, sizeof.TOOLINFOA ; TOOLINFOA = TOOLINFOW
        mov     [esp+TOOLINFOA.cbSize], sizeof.TOOLINFOA
        mov     [esp+TOOLINFOA.uFlags], TTF_IDISHWND or TTF_SUBCLASS
        cmp     edx, LPSTR_TEXTCALLBACK
        jz      .lpstr_textcallback
.loc_a: mov     [esp+TOOLINFOA.uId], ecx
        mov     ecx, [esp+sizeof.TOOLINFOA+_hWndParent]
        mov     [esp+TOOLINFOW.hwnd], ecx
        xor     ecx, ecx
        mov     [esp+TOOLINFOA.rect], ecx
        mov     [esp+TOOLINFOA.lpszText], edx
        mov     [esp+TOOLINFOA.lParam], ecx
        mov     [esp+TOOLINFOA.lpReserved], ecx
        push    ecx eax ecx dword [esp+12+sizeof.TOOLINFOA+_hWndParent] ; for CreateWindowExA [3]
        mov     eax, CW_USEDEFAULT
        push    eax eax eax eax ; for CreateWindowExA [2]
        inc     eax ; CW_USEDEFAULT => WS_POPUP or TTS_ALWAYSTIP
        push    eax ecx .szClassTooltips ecx ; for CreateWindowExA [1]
        call    [CreateWindowExA]
        test    eax, eax
        jz      .restore_stack_and_return
        push    eax
        xor     eax, eax
        cmp     [esp+4+TOOLINFOA.lpszText], LPSTR_TEXTCALLBACK
        jz      .ttm_addtool
        mov     ecx, sizeof.MEMORY_BASIC_INFORMATION
        sub     esp, ecx
        mov     edx, esp
        stdcall c_memset, edx, eax, ecx
        add     esp, 8
        push    eax dword [esp+8+sizeof.MEMORY_BASIC_INFORMATION+4+TOOLINFOA.lpszText]
        call    [VirtualQuery]
        test    eax, eax
        jz      @f
        mov     eax, [esp+MEMORY_BASIC_INFORMATION.AllocationBase]
    @@: add     esp, sizeof.MEMORY_BASIC_INFORMATION

.ttm_addtool:
        lea     ecx, [esp+4]
        mov     [ecx+TOOLINFOA.hinst], eax
        invoke  SendMessageA, dword [esp+12], TTM_ADDTOOL, 0, ecx
        pop     eax

.restore_stack_and_return:
        add     esp, sizeof.TOOLINFOA

.return:
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.lpstr_textcallback:
        mov     [esp+TOOLINFOA.hwnd], ecx
        jmp     .loc_a

align PSEUDO_C_INSTRUCTIONS_ALIGN

.szClassTooltips db 'tooltips_class32', 0

align PSEUDO_C_INSTRUCTIONS_ALIGN

.error_invalid_window_handle:
        invoke  SetLastError, ERROR_INVALID_WINDOW_HANDLE
        xor     eax, eax
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc CreateSimpleToolTipW

_hWndParent = 4
_hTool = 8
_lpszText = 12

        invoke  GetWindowLongW, dword [esp+4+_hWndParent], GWL_HINSTANCE
        test    eax, eax
        jz      .return
        mov     ecx, [esp+_hTool]
        test    ecx, ecx
        jz      .error_invalid_window_handle
        cmp     ecx, INVALID_HANDLE_VALUE
        jz      .error_invalid_window_handle
        mov     edx, [esp+_lpszText]
        sub     esp, sizeof.TOOLINFOW ; TOOLINFOW = TOOLINFOA
        mov     [esp+TOOLINFOW.cbSize], sizeof.TOOLINFOW
        mov     [esp+TOOLINFOW.uFlags], TTF_IDISHWND or TTF_SUBCLASS
        cmp     edx, LPSTR_TEXTCALLBACK
        jz      .lpstr_textcallback
.loc_a: mov     [esp+TOOLINFOW.uId], ecx
        mov     ecx, [esp+sizeof.TOOLINFOW+_hWndParent]
        mov     [esp+TOOLINFOW.hwnd], ecx
        xor     ecx, ecx
        mov     [esp+TOOLINFOW.rect], ecx
        mov     [esp+TOOLINFOW.lpszText], edx
        mov     [esp+TOOLINFOW.lParam], ecx
        mov     [esp+TOOLINFOW.lpReserved], ecx
        push    ecx eax ecx dword [esp+12+sizeof.TOOLINFOW+_hWndParent] ; for CreateWindowExW [3]
        mov     eax, CW_USEDEFAULT
        push    eax eax eax eax ; for CreateWindowExW [2]
        inc     eax ; CW_USEDEFAULT => WS_POPUP or TTS_ALWAYSTIP
        push    eax ecx .szClassTooltips ecx ; for CreateWindowExW [1]
        call    [CreateWindowExW]
        test    eax, eax
        jz      .restore_stack_and_return
        push    eax
        xor     eax, eax
        cmp     [esp+4+TOOLINFOW.lpszText], LPSTR_TEXTCALLBACK
        jz      .ttm_addtool
        mov     ecx, sizeof.MEMORY_BASIC_INFORMATION
        sub     esp, ecx
        mov     edx, esp
        stdcall c_memset, edx, eax, ecx
        add     esp, 8
        push    eax dword [esp+8+sizeof.MEMORY_BASIC_INFORMATION+4+TOOLINFOW.lpszText]
        call    [VirtualQuery]
        test    eax, eax
        jz      @f
        mov     eax, [esp+MEMORY_BASIC_INFORMATION.AllocationBase]
    @@: add     esp, sizeof.MEMORY_BASIC_INFORMATION

.ttm_addtool:
        lea     ecx, [esp+4]
        mov     [ecx+TOOLINFOW.hinst], eax
        invoke  SendMessageW, dword [esp+12], TTM_ADDTOOL, 0, ecx
        pop     eax

.restore_stack_and_return:
        add     esp, sizeof.TOOLINFOW

.return:
        retn    12

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.lpstr_textcallback:
        mov     [esp+TOOLINFOW.hwnd], ecx
        jmp     .loc_a

align PSEUDO_C_INSTRUCTIONS_ALIGN

.szClassTooltips du 'tooltips_class32', 0

align PSEUDO_C_INSTRUCTIONS_ALIGN

.error_invalid_window_handle:
        invoke  SetLastError, ERROR_INVALID_WINDOW_HANDLE
        xor     eax, eax
        retn    12
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc EnableVisualStyles

__stack_length = sizeof.ACTCTX + 4

__actctx = 4

        stdcall ProcessHeapAlloc, NULL, MAX_PATH_LENGTH * sizeof.TCHAR
        test    eax, eax
        jz      .return
        push    ebx
        mov     ebx, eax
        push    esi
        sub     esp, __stack_length
        invoke  GetSystemDirectory, eax, MAX_PATH_LENGTH
        test    eax, eax
        jz      .free_path_buffer_and_return_error
        cmp     eax, MAX_PATH_LENGTH - 1
        ja      .error_insufficient_buffer
        xor     ecx, ecx
        if sizeof.TCHAR = 2
        mov     [ebx+eax*2], cx
        else
        mov     [ebx+eax], cl
        end if
        mov     eax, esp
        ccall   c_memset, eax, ecx, __stack_length
        invoke  GetModuleHandle, .library_kernel32
        test    eax, eax
        jz      .free_path_buffer_and_return_error
        invoke  GetProcAddress, eax, .CreateActCtx
        test    eax, eax
        jz      .free_path_buffer_and_return_error
        lea     ecx, [esp+__actctx]
        mov     [ecx+ACTCTX.cbSize], sizeof.ACTCTX
        mov     [ecx+ACTCTX.dwFlags], ACTCTX_FLAG_RESOURCE_NAME_VALID or ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID or ACTCTX_FLAG_SET_PROCESS_DEFAULT
        mov     edx, .library_shell32
        mov     [ecx+ACTCTX.lpSource], edx
        mov     [ecx+ACTCTX.lpAssemblyDirectory], ebx
        mov     [ecx+ACTCTX.lpResourceName], 124
        stdcall eax, ecx
        cmp     eax, INVALID_HANDLE_VALUE
        jz      .free_path_buffer_and_return_error
        mov     esi, eax
        invoke  GetModuleHandle, .library_kernel32
        test    eax, eax
        jz      .free_path_buffer_and_return_error
        invoke  GetProcAddress, eax, .ActivateActCtx
        test    eax, eax
        jz      .free_path_buffer_and_return_error
        stdcall eax, esi, esp
        test    eax, eax
        jz      .free_path_buffer_and_return_error
        stdcall ProcessHeapFree, ebx
        mov     eax, [esp]

.restore_registers_and_return:
        add     esp, __stack_length
        pop     esi ebx

.return:
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.error_insufficient_buffer:
        mov     esi, ERROR_INSUFFICIENT_BUFFER
        jmp     @f

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.free_path_buffer_and_return_error:
        invoke  GetLastError
        mov     esi, eax
    @@: stdcall ProcessHeapFree, ebx
        invoke  SetLastError, esi
        xor     eax, eax
        jmp     .restore_registers_and_return

align PSEUDO_C_INSTRUCTIONS_ALIGN

.library_kernel32 TCHAR 'KERNEL32.DLL', 0

align PSEUDO_C_INSTRUCTIONS_ALIGN

if sizeof.TCHAR = 2
.CreateActCtx db 'CreateActCtxW', 0
else
.CreateActCtx db 'CreateActCtxA', 0
end if

align PSEUDO_C_INSTRUCTIONS_ALIGN

.ActivateActCtx db 'ActivateActCtx', 0

align PSEUDO_C_INSTRUCTIONS_ALIGN

.library_shell32 TCHAR 'SHELL32.DLL', 0

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc GetStartupShowWindowState
        sub     esp, sizeof.STARTUPINFO
        invoke  GetStartupInfo, esp
        test    byte [esp+STARTUPINFO.dwFlags], STARTF_USESHOWWINDOW
        jz      .default_sw_value
        movzx   eax, word [esp+STARTUPINFO.wShowWindow]
        cmp     eax, SW_FORCEMINIMIZE
        ja      .default_sw_value
    @@: add     esp, sizeof.STARTUPINFO
        retn

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.default_sw_value:
        mov     eax, SW_SHOWNORMAL
        jmp     @b
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc InitCommonControlClasses

_dwICC = 4

        invoke  GetModuleHandle, .COMCTL32.DLL
        test    eax, eax
        jz      .return_true
        invoke  GetProcAddress, eax, .InitCommonControlsEx
        test    eax, eax
        jz      .return_true
        mov     ecx, [esp+_dwICC]
        if defined PSEUDO_C_INSTRUCTION_JECXZ & PSEUDO_C_INSTRUCTION_JECXZ eq TRUE
        jecxz   @f
        else
        test    ecx, ecx
        jz      @f
        end if
        push    eax
        sub     esp, 8 ; = sizeof.INITCOMMONCONTROLSEX
        mov     [esp+INITCOMMONCONTROLSEX.dwSize], 8 ; = sizeof.INITCOMMONCONTROLSEX
        mov     [esp+INITCOMMONCONTROLSEX.dwICC], ecx
        push    esp
        call    dword [esp+4+8]
        add     esp, 8 + 4 ; 8 = sizeof.INITCOMMONCONTROLSEX
        retn    4

        align   PSEUDO_C_INSTRUCTIONS_ALIGN
    @@:
        mov     eax, ecx

.return_true:
        InitCommonControlsStub = InitCommonControls
        inc     al
        retn    4

align PSEUDO_C_INSTRUCTIONS_ALIGN

.COMCTL32.DLL TCHAR 'COMCTL32.DLL', 0
align 4
.InitCommonControlsEx db 'InitCommonControlsEx', 0

endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc MessageBoxSpecialA

_hParentWnd = 4
_lpszText = 8
_lpszCaption = 12
_dwStyle = 16
_hInstance = 20
_lpszIcon = 24

        push    edi
        sub     esp, sizeof.MSGBOXPARAMSA
        mov     edi, esp
        mov     ecx, sizeof.MSGBOXPARAMSA / 4
        xor     eax, eax
        cld
        rep     stosd
        mov     [esp+MSGBOXPARAMSA.cbSize], sizeof.MSGBOXPARAMSA
        mov     eax, [esp+sizeof.MSGBOXPARAMSA+4+_hParentWnd]
        mov     [esp+MSGBOXPARAMSA.hwndOwner], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSA+4+_hInstance]
        mov     [esp+MSGBOXPARAMSA.hInstance], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSA+4+_lpszText]
        mov     [esp+MSGBOXPARAMSA.lpszText], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSA+4+_lpszCaption]
        mov     [esp+MSGBOXPARAMSA.lpszCaption], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSA+4+_dwStyle]
        mov     [esp+MSGBOXPARAMSA.dwStyle], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSA+4+_lpszIcon]
        mov     [esp+MSGBOXPARAMSA.lpszIcon], eax
        invoke  MessageBoxIndirectA, esp
        add     esp, sizeof.MSGBOXPARAMSA
        test    eax, eax
        jnz     @f
        mov     eax, [esp+4+_dwStyle]
        and     eax, 0xFFFFFFFF xor MB_USERICON
        invoke  MessageBoxA, dword [esp+12+4+_hParentWnd], dword [esp+8+4+_lpszText], dword [esp+4+4+_lpszCaption], eax
        test    eax, eax
        jz      .return_system_error_code
    @@: xor     eax, eax

.restore_stack_and_return:
        pop     edi
        retn    24

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_system_error_code:
        invoke  GetLastError
        jmp     .restore_stack_and_return
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc MessageBoxSpecialW

_hParentWnd = 4
_lpszText = 8
_lpszCaption = 12
_dwStyle = 16
_hInstance = 20
_lpszIcon = 24

        push    edi
        sub     esp, sizeof.MSGBOXPARAMSW
        mov     edi, esp
        mov     ecx, sizeof.MSGBOXPARAMSW / 4
        xor     eax, eax
        cld
        rep     stosd
        mov     [esp+MSGBOXPARAMSW.cbSize], sizeof.MSGBOXPARAMSW
        mov     eax, [esp+sizeof.MSGBOXPARAMSW+4+_hParentWnd]
        mov     [esp+MSGBOXPARAMSW.hwndOwner], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSW+4+_hInstance]
        mov     [esp+MSGBOXPARAMSW.hInstance], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSW+4+_lpszText]
        mov     [esp+MSGBOXPARAMSW.lpszText], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSW+4+_lpszCaption]
        mov     [esp+MSGBOXPARAMSW.lpszCaption], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSW+4+_dwStyle]
        mov     [esp+MSGBOXPARAMSW.dwStyle], eax
        mov     eax, [esp+sizeof.MSGBOXPARAMSW+4+_lpszIcon]
        mov     [esp+MSGBOXPARAMSW.lpszIcon], eax
        invoke  MessageBoxIndirectW, esp
        add     esp, sizeof.MSGBOXPARAMSW
        test    eax, eax
        jnz     @f
        mov     eax, [esp+4+_dwStyle]
        and     eax, 0xFFFFFFFF xor MB_USERICON
        invoke  MessageBoxW, dword [esp+12+4+_hParentWnd], dword [esp+8+4+_lpszText], dword [esp+4+4+_lpszCaption], eax
        test    eax, eax
        jz      .return_system_error_code
    @@: xor     eax, eax

.restore_stack_and_return:
        pop     edi
        retn    24

        align   PSEUDO_C_INSTRUCTIONS_ALIGN

.return_system_error_code:
        invoke  GetLastError
        jmp     .restore_stack_and_return
endp

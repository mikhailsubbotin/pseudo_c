# Pseudo C for FASM
x86 API for [flat assembler](http://flatassembler.net/index.php).

Example:
```
format PE Console 4.0
include '%FASMINC%\win32wx.inc' ; "win32a*.inc" - ANSI API | "win32w*.inc" - UNICODE API
if sizeof.TCHAR = 2
entry entry.console.w
else
entry entry.console.a
end if

PSEUDO_C_COMPATIBILITY_WIN9X equ TRUE
PSEUDO_C_USE_ONLY_WINAPI equ TRUE

include '%PSEUDO_C%\pseudo_c.inc'

APPLICATION_AUTHOR equ 'Mikhail Subbotin'
APPLICATION_AUTHOR_WEBSITE equ 'https://github.com/mikhailsubbotin'
APPLICATION_TITLE equ 'Pseudo C: Console Program Example'

section '.code' code readable executable

proc main

_argc = 4
_argv = 8

        push    ebx
        mov     ebx, [esp+4+_argc]
        push    esi
        xor     esi, esi
        push    edi
        mov     edi, [esp+12+_argv]
        stdcall StdOutPrint, title
    @@: stdcall StdOutWrite, argument, sizeof.argument
        push    dword [edi+esi*4] ; for StdOutPrint
        inc     esi
        stdcall StdOutPrintUnsignedInteger, esi
        stdcall StdOutWrite, colon, 2
        call    StdOutPrint
        stdcall StdOutWrite, end_of_line, sizeof.end_of_line
        cmp     esi, ebx
        jb      @b
        xor     eax, eax
        pop     edi esi ebx
        retn
endp

include '%PSEUDO_C%\pseudo_c.asm'

section '.data' data readable

title TCHAR APPLICATION_TITLE
      sizeof.title = ($ - title) / sizeof.TCHAR
   @@ TCHAR ' by ', APPLICATION_AUTHOR
      if defined APPLICATION_AUTHOR_WEBSITE
   @@ TCHAR ' [', APPLICATION_AUTHOR_WEBSITE, ']'
      end if
   @@ TCHAR EOL, sizeof.title dup '-'
end_of_line TCHAR EOL, 0
sizeof.end_of_line = ($ - end_of_line) / sizeof.TCHAR - 1

align 4

argument TCHAR 'Argument #'
sizeof.argument = ($ - argument) / sizeof.TCHAR
colon TCHAR ': '

include '%FASMINC%\allapi.inc'
```

---
Licensed under the MIT License.

© [Mikhail Subbotin](http://github.com/mikhailsubbotin)
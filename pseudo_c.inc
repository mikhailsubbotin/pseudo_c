; Pseudo C / pseudo_c.inc
; -----------------------
; 31.03.2022 © Mikhail Subbotin

EOL_CR = 13
EOL_LF = 10
EOL equ EOL_CR, EOL_LF
sizeof.EOL = 2

display 'Pseudo C for FASM by Mikhail Subbotin', EOL

include 'custom.inc'

include 'errno.inc'
include 'gui.inc'
include 'path.inc'

; Macroses :
; --------

macro compatible_calls link, ansi, widechar
{ if used link
    if sizeof.TCHAR = 2
      link = widechar
    else
      link = ansi
    end if
  end if }

macro fcall proc,[arg] ; fastcall
 { common
    if ~ arg eq
    local count
    count = 0
   forward
    count = count + 1
   reverse
    if count > 2
     count = count - 1
     pushd arg
    else if count = 2
     count = count - 1
     if ~ arg eq edx
      if arg eqtype 0 & arg eq 0
       xor edx,edx
      else
       mov edx,arg
      end if
     end if
    else if ~ arg eq ecx
     if arg eqtype 0 & arg eq 0
      xor ecx,ecx
     else
      mov ecx,arg
     end if
    end if
   common
    end if
    call proc }

macro finvoke proc,[arg] ; fastcall
 { common
    if ~ arg eq
    local count
    count = 0
   forward
    count = count + 1
   reverse
    if count > 2
     count = count - 1
     pushd arg
    else if count = 2
     count = count - 1
     if ~ arg eq edx
      if arg eqtype 0 & arg eq 0
       xor edx,edx
      else
       mov edx,arg
      end if
     end if
    else if ~ arg eq ecx
     if arg eqtype 0 & arg eq 0
       xor ecx,ecx
     else
      mov ecx,arg
     end if
    end if
   common
    end if
    call [proc] }

macro tcall proc,[arg] ; thiscall
 { common
    if ~ arg eq
    local count
    count = 0
   forward
    count = count + 1
   reverse
    if count > 1
     count = count - 1
     pushd arg
    else if ~ arg eq ecx
     if arg eqtype 0 & arg eq 0
      xor ecx,ecx
     else
      mov ecx,arg
     end if
    end if
   common
    end if
    call proc }

macro tinvoke proc,[arg] ; thiscall
 { common
    if ~ arg eq
    local count
    count = 0
   forward
    count = count + 1
   reverse
    if count > 1
     count = count - 1
     pushd arg
    else if ~ arg eq ecx
     if arg eqtype 0 & arg eq 0
      xor ecx,ecx
     else
      mov ecx,arg
     end if
    end if
   common
    end if
    call [proc] }

; Structures :
; ----------

struct C_MAINCMDARGS
  argc dd ?
  argv dd ?
ends

; Constants :
; ---------

_CONSOLE_APP = 1
_GUI_APP = 2

SEEK_SET = 0
SEEK_CUR = 1
SEEK_END = 2

compatible_calls c.integer.to.string, c_itoa, c_itow
compatible_calls c.integer.unsigned.to.string, c_ultoa, c_ultow
compatible_calls c.long.to.string, c_ltoa, c_ltow
compatible_calls c.string.break.on, c_strpbrk, c_wcspbrk
compatible_calls c.string.character.last, c_strrchr, c_wcsrchr
compatible_calls c.string.compare, c_strcmp, c_wcscmp
compatible_calls c.string.compare.n, c_strncmp, c_wcsncmp
compatible_calls c.string.concatenate.s, c_strcat_s, c_wcscat_s
compatible_calls c.string.copy, c_strcpy, c_wcscpy
compatible_calls c.string.copy.s, c_strcpy_s, c_wcscpy_s
compatible_calls c.string.length, c_strlen, c_wcslen
compatible_calls c.string.length.n, c_strnlen, c_wcsnlen

compatible_calls string.to.integer.unsigned.s, atoui_s, wtoui_s

compatible_calls CompatibleRegDeleteKeyEx, CompatibleRegDeleteKeyExA, CompatibleRegDeleteKeyExW
compatible_calls CreateButton, CreateButtonA, CreateButtonW
compatible_calls CreateDirectoryRecursively, CreateDirectoryRecursivelyA, CreateDirectoryRecursivelyW
compatible_calls CreateFileBackup, CreateFileBackupA, CreateFileBackupW
compatible_calls CreateFileBackupEx, CreateFileBackupExA, CreateFileBackupExW
compatible_calls CreateSimpleToolTip, CreateSimpleToolTipA, CreateSimpleToolTipW
compatible_calls DebugBreakpointMessage, DebugBreakpointMessageA, DebugBreakpointMessageW
compatible_calls GetCurrentModuleDirectory, GetCurrentModuleDirectoryA, GetCurrentModuleDirectoryW
compatible_calls GetFileNameFromPath, GetFileNameFromPathA, GetFileNameFromPathW
compatible_calls GetLastNameFromPath, GetLastNameFromPathA, GetLastNameFromPathW
compatible_calls GetModuleFilePath, GetModuleFilePathA, GetModuleFilePathW
compatible_calls GetSpecialNtSystemFolderLocation, GetSpecialNtSystemFolderLocationA, GetSpecialNtSystemFolderLocationW
compatible_calls IsDriveReady, IsDriveReadyA, IsDriveReadyW
compatible_calls IsPathExist, IsPathExistA, IsPathExistW
compatible_calls NewFile, NewFileA, NewFileW
compatible_calls NewFileEx, NewFileExA, NewFileExW
compatible_calls RegGetValueLength, RegGetValueLengthA, RegGetValueLengthW
compatible_calls ReplaceFilePathExtension, ReplaceFilePathExtensionA, ReplaceFilePathExtensionW
compatible_calls StdOutErrorCodePrint, StdOutErrorCodePrintA, StdOutErrorCodePrintW
compatible_calls StdOutPrint, StdOutPrintA, StdOutPrintW
compatible_calls StdOutPrintEx, StdOutPrintExA, StdOutPrintExW
compatible_calls StdOutPrintFormatted, StdOutPrintFormattedA, StdOutPrintFormattedW
compatible_calls StdOutPrintLowerCaseHexadecimal, StdOutPrintLowerCaseHexadecimalA, StdOutPrintLowerCaseHexadecimalW
compatible_calls StdOutPrintUnsignedInteger, StdOutPrintUnsignedIntegerA, StdOutPrintUnsignedIntegerW
compatible_calls StdOutPrintUpperCaseHexadecimal, StdOutPrintUpperCaseHexadecimalA, StdOutPrintUpperCaseHexadecimalW
compatible_calls StdOutPrintUpperCaseHexadecimalEx, StdOutPrintUpperCaseHexadecimalExA, StdOutPrintUpperCaseHexadecimalExW
compatible_calls StdOutWrite, StdOutWriteA, StdOutWriteW
compatible_calls StdOutWriteEx, StdOutWriteExA, StdOutWriteExW
compatible_calls SystemErrorMessage, SystemErrorMessageA, SystemErrorMessageW
compatible_calls Unsigned64bitIntegerToString, Unsigned64bitIntegerToStringA, Unsigned64bitIntegerToStringW
compatible_calls WriteDirectoryPathEndingSlash, WriteDirectoryPathEndingSlashA, WriteDirectoryPathEndingSlashW
compatible_calls WritePrivateProfileInt, WritePrivateProfileIntA, WritePrivateProfileIntW

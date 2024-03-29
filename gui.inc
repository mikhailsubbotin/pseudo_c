; Pseudo C / gui.inc
; ------------------
; 24.04.2023 � Mikhail Subbotin

if ~ definite ACTCTX
struct ACTCTX
  cbSize dd ?
  dwFlags dd ?
  lpSource dd ?
  wProcessorArchitecture dw ?
  wLangId dw ?
  lpAssemblyDirectory dd ?
  lpResourceName dd ?
  lpApplicationName dd ?
  hModule dd ?
ends
end if

if used ACTCTX_FLAG_PROCESSOR_ARCHITECTURE_VALID & ~ definite ACTCTX_FLAG_PROCESSOR_ARCHITECTURE_VALID
ACTCTX_FLAG_PROCESSOR_ARCHITECTURE_VALID = 1
end if
if used ACTCTX_FLAG_LANGID_VALID & ~ definite ACTCTX_FLAG_LANGID_VALID
ACTCTX_FLAG_LANGID_VALID = 2
end if
if used ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID & ~ definite ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID
ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID = 4
end if
if used ACTCTX_FLAG_RESOURCE_NAME_VALID & ~ definite ACTCTX_FLAG_RESOURCE_NAME_VALID
ACTCTX_FLAG_RESOURCE_NAME_VALID = 8
end if
if used ACTCTX_FLAG_SET_PROCESS_DEFAULT & ~ definite ACTCTX_FLAG_SET_PROCESS_DEFAULT
ACTCTX_FLAG_SET_PROCESS_DEFAULT = 16
end if
if used ACTCTX_FLAG_APPLICATION_NAME_VALID & ~ definite ACTCTX_FLAG_APPLICATION_NAME_VALID
ACTCTX_FLAG_APPLICATION_NAME_VALID = 32
end if
if used ACTCTX_FLAG_HMODULE_VALID & ~ definite ACTCTX_FLAG_HMODULE_VALID
ACTCTX_FLAG_HMODULE_VALID = 128
end if

if ~ definite MSGBOXPARAMSA
struct MSGBOXPARAMSA
  cbSize dd ?
  hwndOwner dd ?
  hInstance dd ?
  lpszText dd ?
  lpszCaption dd ?
  dwStyle dd ?
  lpszIcon dd ?
  dwContextHelpId dd ?
  lpfnMsgBoxCallback dd ?
  dwLanguageId dd ?
ends
end if

if ~ definite MSGBOXPARAMSW
struct MSGBOXPARAMSW
  cbSize dd ?
  hwndOwner dd ?
  hInstance dd ?
  lpszText dd ?
  lpszCaption dd ?
  dwStyle dd ?
  lpszIcon dd ?
  dwContextHelpId dd ?
  lpfnMsgBoxCallback dd ?
  dwLanguageId dd ?
ends
end if

; Pseudo C / reflect.asm
; ----------------------
; 28.03.2023 © Mikhail Subbotin

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc reflect_byte_bits

_value = 4

        movzx   eax, byte [esp+_value]
        mov     al, [reflect_byte_bits_table+eax]
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc reflect_word_bits

_value = 4

        movzx   eax, word [esp+_value]
        mov     ax, [reflect_word_bits_table+eax]
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc reflect_dword_bits

_value = 4

        mov     ecx, [esp+_value]
        movzx   edx, cx
        shr     ecx, 16
        mov     ax, [reflect_word_bits_table+edx*2]
        shl     eax, 16
        mov     ax, [reflect_word_bits_table+ecx*2]
        retn    4
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc reflect_byte_bits_table
s = 0
repeat 256
  v = 0
  i = 1
  r = 1 shl 7
  repeat 8
    if s and i
      v = v or r
    end if
    i = i shl 1
    r = r shr 1
  end repeat
  db v
  s = s + 1
end repeat
endp

align PSEUDO_C_INSTRUCTIONS_ALIGN

proc reflect_word_bits_table
s = 0
repeat 65536
  v = 0
  i = 1
  r = 1 shl 15
  repeat 16
    if s and i
      v = v or r
    end if
    i = i shl 1
    r = r shr 1
  end repeat
  dw v
  s = s + 1
end repeat
endp

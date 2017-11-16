defmodule Instruction do
  def two_byte?(<<0x0::size(2)>> <> <<_dest::size(3)>> <> <<0x6::size(3)>>), do: true
  def two_byte?(<<0xFE::size(8)>>), do: true
  def two_byte?(<<0xD6::size(8)>>), do: true
  def two_byte?(<<0x20::size(8)>>), do: true
  def two_byte?(<<0x28::size(8)>>), do: true
  def two_byte?(<<0xed::size(8)>>), do: true
  def two_byte?(<<0xcb::size(8)>>), do: true
  def two_byte?(<<0xd3::size(8)>>), do: true
  def two_byte?(<<0xe6::size(8)>>), do: true
  def two_byte?(<<0x18::size(8)>>), do: true
  def two_byte?(<<0x38::size(8)>>), do: true
  def two_byte?(<<0x10::size(8)>>), do: true
  def two_byte?(<<0x36::size(8)>>), do: true
  def two_byte?(<<0xf6::size(8)>>), do: true
  def two_byte?(_), do: false

  def three_byte?(<<0xC3::size(8)>>), do: true
  def three_byte?(<<0xCD::size(8)>>), do: true
  def three_byte?(<<0x2a::size(8)>>), do: true
  def three_byte?(<<0x32::size(8)>>), do: true
  def three_byte?(<<0x3a::size(8)>>), do: true
  def three_byte?(<<0x22::size(8)>>), do: true
  def three_byte?(<<0xc4::size(8)>>), do: true
  def three_byte?(<<0x3::size(2)>> <> <<_cond_code::size(3)>> <> <<0x2::size(3)>>), do: true
  def three_byte?(<<0::size(2)>> <> <<_dest::size(2)>> <> <<0x1::size(4)>>), do: true
  def three_byte?(_), do: false

  # NOP - 0x00
  def decode(<<0x00::size(8)>>), do: "NOP"

  # RET - 0xc9
  def decode(<<0xC9::size(8)>>), do: "RET"

  # DI - 0xf3
  def decode(<<0xF3::size(8)>>), do: "DI"

  # RST - 0xff
  def decode(<<0xFF::size(8)>>), do: "RST"

  def decode(<<0xE3::size(8)>>), do: "EX (SP), HL"
  def decode(<<0xBE::size(8)>>), do: "CP (HL)"
  def decode(<<0xD9::size(8)>>), do: "EXX"
  def decode(<<0x08::size(8)>>), do: "EX AF, AF'"
  def decode(<<0x1A::size(8)>>), do: "LD A,(DE)"
  def decode(<<0x3F::size(8)>>), do: "CCF"
  def decode(<<0x35::size(8)>>), do: "DEC (HL)"
  def decode(<<0x17::size(8)>>), do: "RLA"
  def decode(<<0xdd::size(8)>>), do: "DD ***"
  def decode(<<0x02::size(8)>>), do: "LD (BC),A"
  def decode(<<0x2f::size(8)>>), do: "CPL"
  def decode(<<0xae::size(8)>>), do: "XOR (HL)"
  def decode(<<0x12::size(8)>>), do: "LD (DE),A"
  def decode(<<0xeb::size(8)>>), do: "EX DE, HL"
  def decode(<<0x8e::size(8)>>), do: "ADC A, (HL)"
  def decode(<<0xe9::size(8)>>), do: "JP (HL)"
  def decode(<<0x86::size(8)>>), do: "ADD A, (HL)"
  def decode(<<0xfb::size(8)>>), do: "EI"
  def decode(<<0xf9::size(8)>>), do: "LD SP, HL"

  def decode(<<0x0e::size(5)>> <> <<dest::size(3)>>) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "LD (HR),#{dest_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -10")
    end
  end

  def decode(<<1::size(2)>> <> <<src::size(3)>> <> <<0x6::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        "LD #{src_mnemonic},(HL)"

      _ ->
        IO.puts("Invalid Instruction -10")
    end
  end

  def decode(<<0::size(2)>> <> <<src::size(3)>> <> <<0x4::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        "INC #{src_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -10")
    end
  end

  def decode(<<0x3::size(2)>> <> <<page::size(3)>> <> <<0x7::size(3)>>) do
    page_val =
      case page do
        0 -> "00h"
        1 -> "08h"
        2 -> "10h"
        3 -> "18h"
        4 -> "20h"
        5 -> "28h"
        6 -> "30h"
        7 -> "38h"
      end

    "RST #{page_val}"
  end

  def decode((<<0x14::size(5)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        "AND #{src_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -1")
        IO.inspect instr
    end
  end

  def decode((<<0x16::size(5)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        "OR #{src_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -1")
        IO.inspect instr
    end
  end

  # LD r,r - 0b01_ddd_sss
  def decode((<<1::size(2)>> <> <<dest::size(3)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case {dest_reg, src_reg} do
      {{:ok, dest_mnemonic}, {:ok, src_mnemonic}} ->
        "LD #{dest_mnemonic},#{src_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -2")
        IO.inspect instr
    end
  end

  def decode((<<0x17::size(5)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        "CP #{src_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -3")
        IO.inspect instr
    end
  end

  def decode(<<0x3::size(2)>> <> <<cond_code::size(3)>> <> <<0x0::size(3)>>) do
    cond_code_val = Decode.cond_code(<<cond_code::size(3)>>)
    "RET #{cond_code_val}"
  end

  def decode(<<0x0::size(2)>> <> <<dest::size(2)>> <> <<0x0b::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "DEC #{dest_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -4")
    end
  end

  def decode(<<0::size(2)>> <> <<dest::size(2)>> <> <<0x3::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "INC #{dest_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -4")
    end
  end

  def decode(<<0x3::size(2)>> <> <<dest::size(2)>> <> <<0x1::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "POP #{dest_mnemonic}"

      _ ->
          IO.puts("Invalid Instruction -5")
    end
  end

  def decode((<<0x12::size(5)>> <> <<dest::size(3)>>) = instr) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "SUB #{dest_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -6")
        IO.inspect instr
    end
  end

  def decode((<<0x10::size(5)>> <> <<dest::size(3)>>) = instr) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "ADD #{dest_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -6")
        IO.inspect instr
    end
  end

  def decode(<<0x0::size(2)>> <> <<dest::size(2)>> <> <<0x9::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "ADD HL,#{dest_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -6")
    end
  end

  def decode(<<0x3::size(2)>> <> <<dest::size(2)>> <> <<0x5::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "PUSH #{dest_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -7")
    end
  end

  def decode((<<0x15::size(5)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        "XOR #{src_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -8")
        IO.inspect instr
    end
  end

  def decode(<<0x0::size(2)>> <> <<src::size(3)>> <> <<0x5::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        "DEC #{src_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -8")
    end
  end
 
  def decode((<<0x11::size(5)>> <> <<dest::size(3)>>) = instr) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "ADC A,#{dest_mnemonic}"

      _ ->
        IO.puts("Invalid Instruction -10")
        IO.inspect instr
    end
  end


  def decode(byte) when is_binary(byte) do
    IO.inspect(<<0>> <> byte)
  end


  def decode(<<0x36::size(8)>>, <<operand::size(8)>>) do
    "LD (HL),#{operand}"
  end

  # LD r, n - 0b00_ddd_110
  def decode((<<0x0::size(2)>> <> <<dest::size(3)>> <> <<0x6::size(3)>>) = instr, << operand::size(8) >>) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "LD #{dest_mnemonic}, #{operand}"

      _ ->
        IO.puts("Invalid Instruction -10")
        IO.inspect instr
    end
  end

  def decode(<<0xD6::size(8)>>, <<operand::size(8)>>) do
    "SUB #{operand}"
  end

  def decode(<<0x20::size(8)>>, <<operand::size(8)>>) do
    "JR NZ,#{operand}"
  end

  def decode(<<0x28::size(8)>>, <<operand::size(8)>>) do
    "JR Z,#{operand}"
  end

  def decode(<<0xFE::size(8)>>, <<operand::size(8)>>) do
    "CP #{operand}"
  end

  def decode(<<0xed::size(8)>>, <<operand::size(8)>>) do
    "ED #{operand} ***"
  end

  def decode(<<0xcb::size(8)>>, <<operand::size(8)>>) do
    "CB #{operand} ***"
  end

  def decode(<<0xd3::size(8)>>, <<operand::size(8)>>) do
    "OUT #{operand}"
  end

  def decode(<<0xe6::size(8)>>, <<operand::size(8)>>) do
    "AND #{operand}"
  end

  def decode(<<0x18::size(8)>>, <<operand::size(8)>>) do
    "JR #{operand}"
  end

  def decode(<<0x38::size(8)>>, <<operand::size(8)>>) do
    "JR C,#{operand}"
  end

  def decode(<<0x10::size(8)>>, <<operand::size(8)>>) do
    "DJNZ #{operand}"
  end

  def decode(<<0xf6::size(8)>>, <<operand::size(8)>>) do
    "OR #{operand}"
  end

  def decode((<<0::size(2)>> <> <<dest::size(2)>> <> <<0x1::size(4)>>) = instr, operand1, operand2) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)
    <<operand::size(16)>> = operand2 <> operand1

    case dest_reg do
      {:ok, dest_mnemonic} ->
        "LD #{dest_mnemonic},#{operand}"

      _ ->
        IO.puts("Invalid Instruction -11")
        IO.inspect instr
    end
  end

  def decode(<<0xC3::8>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    "JP #{operand}"
  end

  def decode(<<0xCD::8>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    "CALL #{operand}"
  end

  def decode(<<0x2a::size(8)>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    "LD HL,(#{operand})"
  end

  def decode(<<0x32::size(8)>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    "LD (#{operand}),A"
  end

  def decode(<<0x3a::size(8)>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    "LD A,(#{operand})"
  end

  def decode(<<0x22::size(8)>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    "LD (#{operand}),HL"
  end

  def decode(<<0x3::size(2)>> <> <<cond_code::size(3)>> <> <<0x2::size(3)>>, operand1, operand2) do
    cond_code_val = Decode.cond_code(<<cond_code::size(3)>>)
    <<operand::size(16)>> = operand2 <> operand1
    "JP #{cond_code_val}, #{operand}"
  end

  def decode(<<0x3::size(2)>> <> <<cond_code::size(3)>> <> <<0x4::size(3)>>, operand1, operand2) do
    cond_code_val = Decode.cond_code(<<cond_code::size(3)>>)
    <<operand::size(16)>> = operand2 <> operand1
    "CALL #{cond_code_val}, #{operand}"
  end
end

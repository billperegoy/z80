defmodule Instruction do
  def two_byte?(<<0x0::size(2)>> <> <<_dest::size(3)>> <> <<0x6::size(3)>>), do: true
  def two_byte?(<<0x0::size(2)>> <> <<_dest::size(3)>> <> <<0x6::size(4)>>), do: true
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
  def two_byte?(_), do: false

  def three_byte?(<<0xC3::size(8)>>), do: true
  def three_byte?(<<0xCD::size(8)>>), do: true
  def three_byte?(<<0x2a::size(8)>>), do: true
  def three_byte?(<<0x32::size(8)>>), do: true
  def three_byte?(<<0x3a::size(8)>>), do: true
  def three_byte?(<<0x22::size(8)>>), do: true
  def three_byte?(<<0x3::size(2)>> <> <<_cond_code::size(3)>> <> <<0x2::size(3)>>), do: true
  def three_byte?(<<0::size(2)>> <> <<_dest::size(2)>> <> <<0x1::size(4)>>), do: true
  def three_byte?(_), do: false

  # NOP - 0x00
  def decode(address, <<0x00::size(8)>>), do: IO.puts("#{address} NOP")

  # RET - 0xc9
  def decode(address, <<0xC9::size(8)>>), do: IO.puts("#{address} RET")

  # DI - 0xf3
  def decode(address, <<0xF3::size(8)>>), do: IO.puts("#{address} DI")

  # RST - 0xff
  def decode(address, <<0xFF::size(8)>>), do: IO.puts("#{address} RST")

  def decode(address, <<0xE3::size(8)>>), do: IO.puts("#{address} EX (SP), HL")
  def decode(address, <<0xBE::size(8)>>), do: IO.puts("#{address} CP (HL)")
  def decode(address, <<0xD9::size(8)>>), do: IO.puts("#{address} EXX")
  def decode(address, <<0x08::size(8)>>), do: IO.puts("#{address} EX AF, AF'")
  def decode(address, <<0x1A::size(8)>>), do: IO.puts("#{address} LD A,(DE)")
  def decode(address, <<0x3F::size(8)>>), do: IO.puts("#{address} CCF")
  def decode(address, <<0x35::size(8)>>), do: IO.puts("#{address} DEC (HL)")
  def decode(address, <<0x17::size(8)>>), do: IO.puts("#{address} RLA")
  def decode(address, <<0xdd::size(8)>>), do: IO.puts("#{address} DD ***")
  def decode(address, <<0x02::size(8)>>), do: IO.puts("#{address} LD (BC),A")
  def decode(address, <<0x2f::size(8)>>), do: IO.puts("#{address} CPL")
  def decode(address, <<0xae::size(8)>>), do: IO.puts("#{address} XOR (HL)")
  def decode(address, <<0x12::size(8)>>), do: IO.puts("#{address} LD (DE),A")

  def decode(address, <<0x0e::size(5)>> <> <<dest::size(3)>>) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} LD (HR),#{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -10")
    end
  end

  def decode(address, <<1::size(2)>> <> <<src::size(3)>> <> <<0x6::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} LD #{src_mnemonic},(HL)")

      _ ->
        IO.puts("Invalid Instruction -10")
    end
  end

  def decode(address, <<0::size(2)>> <> <<src::size(3)>> <> <<0x4::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} INC #{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -10")
    end
  end

  def decode(address, <<0x3::size(2)>> <> <<page::size(3)>> <> <<0x7::size(3)>>) do
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

    IO.puts("#{address} RST #{page_val}")
  end

  def decode(address, (<<0x14::size(5)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} AND #{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -1")
        IO.inspect instr
    end
  end

  def decode(address, (<<0x16::size(5)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} OR #{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -1")
        IO.inspect instr
    end
  end

  # LD r,r - 0b01_ddd_sss
  def decode(address, (<<1::size(2)>> <> <<dest::size(3)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case {dest_reg, src_reg} do
      {{:ok, dest_mnemonic}, {:ok, src_mnemonic}} ->
        IO.puts("#{address} LD #{dest_mnemonic},#{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -2")
        IO.inspect instr
    end
  end

  def decode(address, (<<0x17::size(5)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} CP #{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -3")
        IO.inspect instr
    end
  end

  def decode(address, <<0x3::size(2)>> <> <<cond_code::size(3)>> <> <<0x0::size(3)>>) do
    cond_code_val = Decode.cond_code(<<cond_code::size(3)>>)
    IO.puts("#{address} RET #{cond_code_val}")
  end

  def decode(address, <<0x0::size(2)>> <> <<dest::size(2)>> <> <<0x0b::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} DEC #{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -4")
        Kernel.exit("Stopping")
    end
  end

  def decode(address, <<0::size(2)>> <> <<dest::size(2)>> <> <<0x3::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} INC #{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -4")
        Kernel.exit("Stopping")
    end
  end

  def decode(address, <<0x3::size(2)>> <> <<dest::size(2)>> <> <<0x1::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} POP #{dest_mnemonic}")

      _ ->
          IO.puts("Invalid Instruction -5")
        Kernel.exit("Stopping")
    end
  end

  def decode(address, <<0x12::size(5)>> <> <<dest::size(3)>>) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} SUB #{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -6")
        Kernel.exit("Stopping")
    end
  end

  def decode(address, <<0x10::size(5)>> <> <<dest::size(3)>>) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} ADD #{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -6")
        Kernel.exit("Stopping")
    end
  end

  def decode(address, <<0x0::size(2)>> <> <<dest::size(2)>> <> <<0x9::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} ADD HL,#{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -6")
        Kernel.exit("Stopping")
    end
  end

  def decode(address, <<0x3::size(2)>> <> <<dest::size(2)>> <> <<0x5::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} PUSH #{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -7")
        Kernel.exit("Stopping")
    end
  end

  def decode(address, (<<0x15::size(5)>> <> <<src::size(3)>>) = instr) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} XOR #{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -8")
        IO.inspect instr
    end
  end

  def decode(address, <<0x0::size(2)>> <> <<src::size(3)>> <> <<0x5::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} DEC #{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -8")
    end
  end
 
  def decode(address, <<0x11::size(5)>> <> <<dest::size(3)>>) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} ADC A,#{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction -10")
    end
  end


  def decode(address, byte) when is_binary(byte) do
    IO.inspect(<<0>> <> byte)
    # Kernel.exit("Stopping")
  end

  # LD r, n - 0b00_ddd_110
  def decode(address, <<0::size(2)>> <> <<dest::size(3)>> <> <<0x6::size(3)>>, << operand::size(8) >>) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} LD #{dest_mnemonic},#{operand}")

      _ ->
        IO.puts("Invalid Instruction -10")
    end
  end

  def decode(address, <<0xD6::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} SUB #{operand}")
  end

  def decode(address, <<0x20::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} JR NZ,#{operand}")
  end

  def decode(address, <<0x28::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} JR Z,#{operand}")
  end

  def decode(address, <<0xFE::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} CP #{operand}")
  end

  def decode(address, <<0xed::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} ED #{operand} ***")
  end

  def decode(address, <<0xcb::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} CB #{operand} ***")
  end

  def decode(address, <<0xd3::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} OUT #{operand}")
  end

  def decode(address, <<0xe6::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} AND #{operand}")
  end

  def decode(address, <<0x18::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} JR #{operand}")
  end

  def decode(address, <<0x38::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} JR C,#{operand}")
  end

  def decode(address, <<0x10::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} DJNZ #{operand}")
  end

  def decode(address, (<<0::size(2)>> <> <<dest::size(2)>> <> <<0x1::size(4)>>) = instr, operand1, operand2) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)
    <<operand::size(16)>> = operand2 <> operand1

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} LD #{dest_mnemonic},#{operand}")

      _ ->
        IO.puts("Invalid Instruction -11")
        IO.inspect instr
        Kernel.exit("Stopping")
    end
  end

  def decode(address, <<0xC3::8>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    IO.puts("#{address} JP #{operand}")
  end

  def decode(address, <<0xCD::8>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    IO.puts("#{address} CALL #{operand}")
  end

  def decode(address, <<0x2a::size(8)>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    IO.puts("#{address} LD HL,(#{operand})")
  end

  def decode(address, <<0x32::size(8)>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    IO.puts("#{address} LD (#{operand}),A")
  end

  def decode(address, <<0x3a::size(8)>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    IO.puts("#{address} LD A,(#{operand})")
  end

  def decode(address, <<0x22::size(8)>>, operand1, operand2) do
    <<operand::size(16)>> = operand2 <> operand1
    IO.puts("#{address} LD (#{operand}),HL")
  end

  def decode(address, <<0x3::size(2)>> <> <<cond_code::size(3)>> <> <<0x2::size(3)>>, operand1, operand2) do
    cond_code_val = Decode.cond_code(<<cond_code::size(3)>>)
    <<operand::size(16)>> = operand2 <> operand1
    IO.puts("#{address} JP #{cond_code_val}, #{operand}")
  end
end

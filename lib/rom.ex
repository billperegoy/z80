defmodule Rom do
  def extract(rom) do
    extract(rom, 0)
  end

  def extract(<<>>, _address), do: nil

  def extract(rom, address) do
    <<byte::8>> <> rest = rom

    if Instruction.two_byte?(<<byte::8>>) do
      <<operand::size(8)>> <> rest = rest
      decode_instruction(address, <<byte::8>>, <<operand::8>>)
      extract(rest, address + 2)
    else
      if Instruction.three_byte?(<<byte::8>>) do
        <<operand1::size(8)>> <> <<operand2::size(8)>> <> rest = rest
        decode_instruction(address, <<byte::8>>, <<operand1::8>>, <<operand2::8>>)
        extract(rest, address + 3)
      else
        decode_instruction(address, <<byte::8>>)
        extract(rest, address + 1)
      end
    end
  end

  # NOP - 0x00
  def decode_instruction(address, <<0x00::8>>), do: IO.puts("#{address} NOP")

  # RET - 0xc9
  def decode_instruction(address, <<0xC9::8>>), do: IO.puts("#{address} RET")

  # DI - 0xf3
  def decode_instruction(address, <<0xF3::8>>), do: IO.puts("#{address} DI")

  # RST - 0xff
  def decode_instruction(address, <<0xFF::8>>), do: IO.puts("#{address} RST")

  def decode_instruction(address, <<0xE3::8>>), do: IO.puts("#{address} EX (SP), HL")
  def decode_instruction(address, <<0xBE::8>>), do: IO.puts("#{address} CP (HL)")
  def decode_instruction(address, <<0xD9::8>>), do: IO.puts("#{address} EXX")
  def decode_instruction(address, <<0x08::8>>), do: IO.puts("#{address} EX AF, AF'")
  def decode_instruction(address, <<0x1A::8>>), do: IO.puts("#{address} LD A, (DE)")
  def decode_instruction(address, <<0x3F::8>>), do: IO.puts("#{address} CCF")

  def decode_instruction(address, <<0x3::size(2)>> <> <<page::size(3)>> <> <<0x7::size(3)>>) do
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

  def decode_instruction(address, <<0x14::size(5)>> <> <<src::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} AND #{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction")
    end
  end

  # LD r,r - 0b01_ddd_sss
  def decode_instruction(address, <<1::size(2)>> <> <<dest::size(3)>> <> <<src::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case {dest_reg, src_reg} do
      {{:ok, dest_mnemonic}, {:ok, src_mnemonic}} ->
        IO.puts("#{address} LD #{dest_mnemonic},#{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction")
    end
  end

  def decode_instruction(address, <<0x17::size(5)>> <> <<src::size(3)>>) do
    src_reg = Decode.reg8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts("#{address} CP #{src_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction")
    end
  end

  def decode_instruction(address, <<0x3::size(2)>> <> <<cond_code::size(3)>> <> <<0x0::size(3)>>) do
    cond_code_val = Decode.cond_code(<<cond_code::size(3)>>)
    IO.puts("#{address} RET #{cond_code_val}")
  end

  def decode_instruction(address, <<0::size(2)>> <> <<dest::size(2)>> <> <<0x3::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} INC #{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction")
        Kernel.exit("Stopping")
    end
  end

  def decode_instruction(address, <<0x3::size(2)>> <> <<dest::size(2)>> <> <<0x1::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} POP #{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction")
        Kernel.exit("Stopping")
    end
  end

  def decode_instruction(address, <<0x0::size(2)>> <> <<dest::size(2)>> <> <<0x9::size(4)>>) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} ADD HL,#{dest_mnemonic}")

      _ ->
        IO.puts("Invalid Instruction")
        Kernel.exit("Stopping")
    end
  end

  def decode_instruction(address, byte) when is_binary(byte) do
    IO.inspect(byte)
    # Kernel.exit("Stopping")
  end

  # LD r, n - 0b00_ddd_110
  def decode_instruction(address, <<0::size(2)>> <> <<dest::size(3)>> <> <<0x6::size(3)>>, <<
        operand::size(8)
      >>) do
    dest_reg = Decode.reg8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} LD #{dest_mnemonic},#{operand}")

      _ ->
        IO.puts("Invalid Instruction")
    end
  end

  def decode_instruction(address, <<0xD6::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} SUB #{operand}")
  end

  def decode_instruction(address, <<0x20::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} JR NZ,#{operand}")
  end

  def decode_instruction(address, <<0x28::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} JR Z,#{operand}")
  end

  def decode_instruction(address, <<0xFE::size(8)>>, <<operand::size(8)>>) do
    IO.puts("#{address} CP #{operand}")
  end

  def decode_instruction(
        address,
        <<0::size(2)>> <> <<dest::size(2)>> <> <<0x1::size(4)>>,
        operand1,
        operand2
      ) do
    dest_reg = Decode.reg16(<<dest::size(2)>>)
    <<operand::16>> = operand2 <> operand1

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts("#{address} LD #{dest_mnemonic},#{operand}")

      _ ->
        IO.puts("Invalid Instruction")
        Kernel.exit("Stopping")
    end
  end

  def decode_instruction(address, <<0xC3::8>>, operand1, operand2) do
    <<operand::16>> = operand2 <> operand1
    IO.puts("#{address} JP #{operand}")
  end

  def decode_instruction(address, <<0xCD::8>>, operand1, operand2) do
    <<operand::16>> = operand2 <> operand1
    IO.puts("#{address} CALL #{operand}")
  end
end

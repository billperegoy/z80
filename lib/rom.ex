defmodule Rom do
  def extract(rom) do
    extract(rom, 0)
  end

  def extract(<<>>, _address), do: nil

  def extract(rom, address) do
    <<byte::8>> <> rest = rom

    if two_byte_instruction?(<<byte::8>>) do
      <<operand:: size(8)>> <> rest = rest
      decode_instruction(address, <<byte::8>>, <<operand::8>>);
      extract(rest, address + 2)
    else
      if three_byte_instruction?(<<byte::8>>) do
      <<operand1:: size(8)>> <> <<operand2:: size(8)>> <> rest = rest
        decode_instruction(address, <<byte::8>>, <<operand1::8>>, <<operand2::8>>);
        extract(rest, address + 3)
      else
        decode_instruction(address, <<byte::8>>);
        extract(rest, address + 1)
      end
    end
  end


  def two_byte_instruction?(<<0::size(2)>> <> <<_dest::size(3)>> <> <<0x6::size(3)>>), do:  true
  def two_byte_instruction?(<<0xfe::size(8)>>), do:  true
  def two_byte_instruction?(<<0xd6::size(8)>>), do:  true
  def two_byte_instruction?(<<0x20::size(8)>>), do:  true
  def two_byte_instruction?(<<0x28::size(8)>>), do:  true
  def two_byte_instruction?(_), do: false

  def three_byte_instruction?(<<0xc3::size(8)>>), do:  true
  def three_byte_instruction?(<<0xcd::size(8)>>), do:  true
  def three_byte_instruction?(<<0::size(2)>> <> <<_dest::size(2)>> <> <<0x1::size(4)>>), do:  true
  def three_byte_instruction?(_), do: false

  # NOP - 0x00
  def decode_instruction(address, <<0x00::8>>), do: IO.puts "#{address} NOP"

  # RET - 0xc9
  def decode_instruction(address, <<0xc9::8>>), do: IO.puts "#{address} RET"

  # DI - 0xf3
  def decode_instruction(address, <<0xf3::8>>), do: IO.puts "#{address} DI"

  # RST - 0xff
  def decode_instruction(address, <<0xff::8>>), do: IO.puts "#{address} RST"

  def decode_instruction(address, <<0xe3::8>>), do: IO.puts "#{address} EX (SP), HL"
  def decode_instruction(address, <<0xbe::8>>), do: IO.puts "#{address} CP (HL)"
  def decode_instruction(address, <<0xd9::8>>), do: IO.puts "#{address} EXX"
  def decode_instruction(address, <<0x08::8>>), do: IO.puts "#{address} EX AF, AF'"
  def decode_instruction(address, <<0x1a::8>>), do: IO.puts "#{address} LD A, (DE)"
  def decode_instruction(address, <<0x3f::8>>), do: IO.puts "#{address} CCF"

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
    IO.puts "#{address} RST #{page_val}"
  end
    
  def decode_instruction(address, <<0x14::size(5)>> <> <<src::size(3)>>) do
    src_reg = decode_register8(<<src::size(3)>>)

    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts "#{address} AND #{src_mnemonic}"

      _ ->
        IO.puts "Invalid Instruction"
    end
    
  end

  # LD r,r - 0b01_ddd_sss
  def decode_instruction(address, <<1::size(2)>> <> <<dest::size(3)>> <> <<src::size(3)>>) do
    src_reg = decode_register8(<<src::size(3)>>)
    dest_reg = decode_register8(<<dest::size(3)>>)

    case {dest_reg, src_reg} do
      {{:ok, dest_mnemonic}, { :ok, src_mnemonic}} ->
        IO.puts "#{address} LD #{dest_mnemonic},#{src_mnemonic}"

      _ ->
        IO.puts "Invalid Instruction"
    end
  end

  def decode_instruction(address, <<0x17::size(5)>> <> <<src::size(3)>>) do
    src_reg = decode_register8(<<src::size(3)>>)
    case src_reg do
      {:ok, src_mnemonic} ->
        IO.puts "#{address} CP #{src_mnemonic}"

      _ ->
        IO.puts "Invalid Instruction"
    end
  end

  def decode_instruction(address, <<0x3::size(2)>> <> <<cond_code::size(3)>> <> <<0x0::size(3)>>) do
    cond_code_val = decode_cond_code(<<cond_code::size(3)>>)
    IO.puts "#{address} RET #{cond_code_val}"
  end

  def decode_instruction(address, <<0::size(2)>> <> <<dest::size(2)>> <> <<0x3::size(4)>>) do
    dest_reg = decode_register16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts "#{address} INC #{dest_mnemonic}"

      _ ->
        IO.puts "Invalid Instruction"
        Kernel.exit("Stopping")
    end
  end

  def decode_instruction(address, <<0x3::size(2)>> <> <<dest::size(2)>> <> <<0x1::size(4)>>) do
    dest_reg = decode_register16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts "#{address} POP #{dest_mnemonic}"

      _ ->
        IO.puts "Invalid Instruction"
        Kernel.exit("Stopping")
    end
  end

  def decode_instruction(address, <<0x0::size(2)>> <> <<dest::size(2)>> <> <<0x9::size(4)>>) do
    dest_reg = decode_register16(<<dest::size(2)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts "#{address} ADD HL,#{dest_mnemonic}"

      _ ->
        IO.puts "Invalid Instruction"
        Kernel.exit("Stopping")
    end
  end

  def decode_instruction(address, byte) when is_binary(byte) do
    IO.inspect byte
    #Kernel.exit("Stopping")
  end

  # LD r, n - 0b00_ddd_110
  def decode_instruction(address, <<0::size(2)>> <> <<dest::size(3)>> <> <<0x6::size(3)>>, <<operand::size(8)>>) do
    dest_reg = decode_register8(<<dest::size(3)>>)

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts "#{address} LD #{dest_mnemonic},#{operand}"

      _ ->
        IO.puts "Invalid Instruction"

    end
  end

  def decode_instruction(address, <<0xd6::size(8)>>, <<operand::size(8)>>) do
    IO.puts "#{address} SUB #{operand}"
  end

  def decode_instruction(address, <<0x20::size(8)>>, <<operand::size(8)>>) do
    IO.puts "#{address} JR NZ,#{operand}"
  end

  def decode_instruction(address, <<0x28::size(8)>>, <<operand::size(8)>>) do
    IO.puts "#{address} JR Z,#{operand}"
  end

  def decode_instruction(address, <<0xfe::size(8)>>, <<operand::size(8)>>) do
    IO.puts "#{address} CP #{operand}"
  end

  def decode_instruction(address, <<0::size(2)>> <> <<dest::size(2)>> <> <<0x1::size(4)>>, operand1, operand2) do
    dest_reg = decode_register16(<<dest::size(2)>>)
    <<operand::16>> = operand2 <> operand1

    case dest_reg do
      {:ok, dest_mnemonic} ->
        IO.puts "#{address} LD #{dest_mnemonic},#{operand}"

      _ ->
        IO.puts "Invalid Instruction"
        Kernel.exit("Stopping")
    end
  end

  def decode_instruction(address, <<0xc3::8>>, operand1, operand2) do
    <<operand::16>> = operand2 <> operand1
    IO.puts "#{address} JP #{operand}"
  end

  def decode_instruction(address, <<0xcd::8>>, operand1, operand2) do
    <<operand::16>> = operand2 <> operand1
    IO.puts "#{address} CALL #{operand}"
  end

  def decode_register8(<<7::size(3)>>), do: {:ok, "A"}
  def decode_register8(<<0::size(3)>>), do: {:ok, "B"}
  def decode_register8(<<1::size(3)>>), do: {:ok, "C"}
  def decode_register8(<<2::size(3)>>), do: {:ok, "D"}
  def decode_register8(<<3::size(3)>>), do: {:ok, "E"}
  def decode_register8(<<4::size(3)>>), do: {:ok, "H"}
  def decode_register8(<<5::size(3)>>), do: {:ok, "L"}
  def decode_register8(_), do: {:error, "Unknown register"}

  def decode_register16(<<0::size(2)>>), do: {:ok, "BC"}
  def decode_register16(<<1::size(2)>>), do: {:ok, "DE"}
  def decode_register16(<<2::size(2)>>), do: {:ok, "HL"}
  def decode_register16(<<3::size(2)>>), do: {:ok, "SP"}

  def decode_cond_code(<<0x0::size(3)>>), do: "NZ"
  def decode_cond_code(<<0x1::size(3)>>), do: "Z"
  def decode_cond_code(<<0x2::size(3)>>), do: "NC"
  def decode_cond_code(<<0x3::size(3)>>), do: "C"
  def decode_cond_code(<<0x4::size(3)>>), do: "PO"
  def decode_cond_code(<<0x5::size(3)>>), do: "PE"
  def decode_cond_code(<<0x6::size(3)>>), do: "P"
  def decode_cond_code(<<0x7::size(3)>>), do: "M"
end

{:ok, rom} = File.read("/Users/bill/Projects/elm-z80/level1.rom") 
Rom.extract(rom)

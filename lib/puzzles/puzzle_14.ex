defmodule AdventOfCode.Puzzle14 do
  use AdventOfCode.Puzzle, no: 14

  defmodule Emulator do
    defstruct ip: 0, pgm: [], ram: %{}, mask: nil, acc: 0, rwm: nil
  end

  def parse_input do
    instruction_patterns = [
      ~r/^mask = (?<mask>[01X]+)$/,
      ~r/^mem\[(?<address>\d+)\] = (?<value>\d+)$/
    ]

    parse_mask = fn mask ->
      mask
      |> String.reverse()
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {symbol, at} ->
        {at,
         case symbol do
           "X" -> :floating
           "1" -> :set
           "0" -> :unset
         end}
      end)
    end

    get_input()
    |> Enum.map(fn instruction ->
      instruction_patterns
      |> Enum.find_value(&Regex.named_captures(&1, instruction))
      |> case do
        %{"mask" => mask} ->
          {:set_mask, parse_mask.(mask)}

        %{"address" => address, "value" => value} ->
          {:write_at, String.to_integer(address), String.to_integer(value)}
      end
    end)
  end

  def apply_mask(value, mask) do
    mask
    |> Stream.filter(&(elem(&1, 1) == :set or elem(&1, 1) == :unset))
    |> Enum.reduce(%Bitmap.Integer{data: value, size: 36}, fn {mask_pos, mask_setting}, bitmap ->
      apply(Bitmap, mask_setting, [bitmap, mask_pos])
    end)
    |> (& &1.data).()
  end

  def compute_mirrored_addresses(base_address, mask) do
    floating_positions = mask |> Enum.filter(&(elem(&1, 1) == :floating))
    floating_positions_count = Enum.count(floating_positions)

    0..(Math.pow(2, floating_positions_count) - 1)
    |> Enum.map(fn floating_mask ->
      floating_mask_bitmap = %Bitmap.Integer{data: floating_mask, size: floating_positions_count}

      floating_positions_relative_offsets =
        floating_positions
        |> Stream.with_index()
        |> Enum.reduce(%{}, fn {{pos, _}, offset}, acc ->
          Map.put(acc, pos, offset)
        end)

      value_mask =
        mask
        |> Enum.map(fn {pos, symbol} ->
          {pos,
           case symbol do
             :unset ->
               :floating

             :set ->
               :set

             :floating ->
               case Bitmap.at(floating_mask_bitmap, floating_positions_relative_offsets[pos]) do
                 0 -> :unset
                 1 -> :set
               end
           end}
        end)

      apply_mask(base_address, value_mask)
    end)
  end

  def write_ram(
        %Emulator{ram: ram, mask: mask, acc: acc} = state,
        address,
        value,
        write_mode
      ) do
    case write_mode do
      :direct ->
        %{state | ram: Map.put(ram, address, value), acc: acc - Map.get(ram, address, 0) + value}

      :direct_masked ->
        write_ram(state, address, apply_mask(value, mask), :direct)

      :mirrored ->
        compute_mirrored_addresses(address, mask)
        |> Enum.reduce(state, &write_ram(&2, &1, value, :direct))
    end
  end

  def run(%Emulator{ip: ip, pgm: pgm, rwm: ram_write_mode} = state) do
    case Enum.at(pgm, ip) do
      nil ->
        state

      instruction ->
        case instruction do
          {:set_mask, mask} -> %{state | mask: mask}
          {:write_at, address, value} -> write_ram(state, address, value, ram_write_mode)
        end
        |> (&run(%{&1 | ip: ip + 1})).()
    end
  end

  def boot(pgm, ram_write_mode), do: run(%Emulator{pgm: pgm, rwm: ram_write_mode})

  def resolve_first_part, do: parse_input() |> boot(:direct_masked) |> (& &1.acc).()
  def resolve_second_part, do: parse_input() |> boot(:mirrored) |> (& &1.acc).()
end

defmodule AdventOfCode.Puzzle5 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  @lower "L"
  @upper "U"

  def get_input(), do: InputReader.read_input(5)

  def dichotomic_search(left_bound..right_bound, [last_direction | []]) do
    case last_direction do
      @lower -> left_bound
      @upper -> right_bound
    end
  end

  def dichotomic_search(left_bound..right_bound, [direction | next_directions]) do
    mid = div(left_bound + right_bound, 2)

    case direction do
      @lower -> left_bound..mid
      @upper -> (mid + 1)..right_bound
    end
    |> dichotomic_search(next_directions)
  end

  def decode_seat(seat_code) do
    seat_code
    |> String.replace(~r/[BR]/iu, @upper)
    |> String.replace(~r/F/iu, @lower)
    |> String.split_at(7)
    |> (fn {row, column} -> {String.codepoints(row), String.codepoints(column)} end).()
    |> (fn {row, column} -> {dichotomic_search(0..127, row), dichotomic_search(0..7, column)} end).()
  end

  def to_seat_ids(seat_codes) do
    seat_codes
    |> Enum.map(&decode_seat/1)
    |> Enum.map(fn {row, column} -> row * 8 + column end)
  end

  def missing_id(seat_ids) do
    seat_ids
    |> Enum.sort()
    |> Enum.drop(-1)
    |> Enum.chunk_every(2)
    |> Enum.find(fn [first, second] -> second - first != 1 end)
    |> (fn [previous, _] -> previous + 1 end).()
  end

  def resolve_first_part(), do: get_input() |> to_seat_ids |> Enum.max()
  def resolve_second_part(), do: get_input() |> to_seat_ids |> missing_id
end

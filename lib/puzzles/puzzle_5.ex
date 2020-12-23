defmodule AdventOfCode.Puzzle5 do
  use AdventOfCode.Puzzle, no: 5

  @lower "L"
  @upper "U"

  def parse_input(), do: get_input()

  def binary_search(left_bound..right_bound, directions) do
    case directions do
      [last_direction | []] ->
        case last_direction do
          @lower -> left_bound
          @upper -> right_bound
        end

      [new_direction | next_directions] ->
        mid = div(left_bound + right_bound, 2)

        case new_direction do
          @lower -> left_bound..mid
          @upper -> (mid + 1)..right_bound
        end
        |> binary_search(next_directions)
    end
  end

  def decode_seat(seat_code) do
    seat_code
    |> String.replace(~r/[BR]/iu, @upper)
    |> String.replace(~r/F/iu, @lower)
    |> String.split_at(7)
    |> (fn {row, column} ->
          {binary_search(0..127, String.codepoints(row)),
           binary_search(0..7, String.codepoints(column))}
        end).()
  end

  def to_seat_ids(seat_codes) do
    seat_codes
    |> Stream.map(&decode_seat/1)
    |> Stream.map(fn {row, column} -> row * 8 + column end)
  end

  def missing_id(seat_ids) do
    seat_ids
    |> Enum.sort()
    |> Stream.chunk_every(2, 2, :discard)
    |> Enum.find(fn [first, second] -> second - first != 1 end)
    |> (&(hd(&1) + 1)).()
  end

  def resolve_first_part(), do: get_input() |> to_seat_ids |> Enum.max()
  def resolve_second_part(), do: get_input() |> to_seat_ids |> missing_id
end

defmodule AdventOfCode.Puzzle21 do
  use AdventOfCode.Puzzle, no: 21

  def parse_input do
    get_input()
    |> Stream.map(fn line ->
      nil
    end)
  end

  def resolve_first_part, do: parse_input()
  def resolve_second_part, do: parse_input()
end

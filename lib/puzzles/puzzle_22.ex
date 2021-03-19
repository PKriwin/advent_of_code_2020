defmodule AdventOfCode.Puzzle22 do
  use AdventOfCode.Puzzle, no: 22

  def parse_input do
    {player_1_deck, player_2_deck} = get_input() |> Enum.split(26)
  end

  def resolve_first_part, do: parse_input()
  def resolve_second_part, do: parse_input()
end

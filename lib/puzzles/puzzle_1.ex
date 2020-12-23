defmodule AdventOfCode.Puzzle1 do
  use AdventOfCode.Puzzle, no: 1

  def parse_input(), do: get_input() |> Enum.map(&String.to_integer/1)

  def find_result_for(input, set_size) do
    Comb.combinations(input, set_size)
    |> Enum.find(&(Enum.sum(&1) == 2020))
    |> Enum.reduce(1, &(&1 * &2))
  end

  def resolve_first_part(), do: parse_input() |> find_result_for(2)
  def resolve_second_part(), do: parse_input() |> find_result_for(3)
end

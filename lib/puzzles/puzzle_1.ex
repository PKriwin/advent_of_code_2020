defmodule AdventOfCode.Puzzle1 do
  use AdventOfCode.Puzzle, no: 1

  def parse_input, do: get_input() |> Enum.map(&String.to_integer/1)

  def find_result_for(input, set_size) do
    Comb.combinations(input, set_size)
    |> Enum.find_value(fn [a, b] -> if a + b == 2020, do: a * b end)
  end

  def resolve_first_part, do: parse_input() |> find_result_for(2)
  def resolve_second_part, do: parse_input() |> find_result_for(3)
end

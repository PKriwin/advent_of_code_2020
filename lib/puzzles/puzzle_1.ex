defmodule AdventOfCode.Puzzle1 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  def get_input(), do: InputReader.read_input(1) |> Enum.map(&String.to_integer/1)

  def find_result_for(input, set_size) do
    Comb.combinations(input, set_size)
    |> Enum.find(&(Enum.sum(&1) == 2020))
    |> Enum.reduce(1, &(&1 * &2))
  end

  def resolve_first_part(), do: get_input() |> find_result_for(2)
  def resolve_second_part(), do: get_input() |> find_result_for(3)
end

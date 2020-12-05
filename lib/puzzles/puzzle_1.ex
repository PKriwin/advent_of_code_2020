defmodule AdventOfCode.Puzzle1 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  def get_input(), do: InputReader.read_input(1) |> Enum.map(&String.to_integer/1)

  def find_result_for(input, set_size) do
    Comb.combinations(input, set_size)
    |> Enum.find(fn set -> Enum.sum(set) == 2020 end)
    |> Enum.reduce(1, fn val, acc -> val * acc end)
  end

  def resolve_first_part() do
    Utils.resolve_puzzle(&get_input/0, &find_result_for(&1, 2))
  end

  def resolve_second_part() do
    Utils.resolve_puzzle(&get_input/0, &find_result_for(&1, 3))
  end
end

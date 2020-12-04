defmodule AdventOfCode.Puzzle1 do
  alias AdventOfCode.Utils.{InputReader}

  def resolve do
    InputReader.read_input(1)
    |> Enum.map(&String.to_integer/1)
    |> find_result
    |> IO.puts()
  end

  def find_result([_ | []]), do: "no result"

  def find_result([number | tail]) do
    case tail |> Enum.find(fn item -> number + item == 2020 end) do
      nil -> find_result(tail)
      value -> number * value
    end
  end
end

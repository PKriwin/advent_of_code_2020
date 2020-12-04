defmodule AdventOfCode.Utils.InputReader do
  def read_input(puzzle_number) do
    Path.join([:code.priv_dir(:advent_of_code), "inputs", "puzzle_#{puzzle_number}.txt"])
    |> File.read!()
    |> String.split("\n")
  end
end

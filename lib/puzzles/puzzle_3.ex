defmodule AdventOfCode.Puzzle3 do
  use AdventOfCode.Puzzle, no: 3
  def parse_input, do: get_input()

  def count_trees(areas, {down, right} = _movement) do
    areas
    |> Stream.drop(down)
    |> Stream.take_every(down)
    |> Stream.with_index()
    |> Enum.reduce(0, fn {area, index}, trees_count ->
      area
      |> String.codepoints()
      |> Enum.at(rem(index * right + right, String.length(area)))
      |> case do
        "#" -> trees_count + 1
        "." -> trees_count
      end
    end)
  end

  def multiply_trees_counts(areas) do
    slopes = [{1, 1}, {1, 3}, {1, 5}, {1, 7}, {2, 1}]

    slopes
    |> Enum.map(&count_trees(areas, &1))
    |> Enum.reduce(1, &(&1 * &2))
  end

  def resolve_first_part, do: parse_input() |> count_trees({1, 3})
  def resolve_second_part, do: parse_input() |> multiply_trees_counts
end

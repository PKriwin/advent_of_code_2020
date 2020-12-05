defmodule AdventOfCode.Puzzle3 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  def get_input(), do: InputReader.read_input(3)

  def count_trees(areas, _movement = {down, right}) do
    areas
    |> Enum.drop(down)
    |> Enum.take_every(down)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {area, index}, trees_count ->
      zone = rem(index * right + right, String.length(area))
      zone_content = area |> String.codepoints() |> Enum.at(zone)

      trees_count + if zone_content == "#", do: 1, else: 0
    end)
  end

  def multiply_trees_counts(areas) do
    slopes = [{1, 1}, {1, 3}, {1, 5}, {1, 7}, {2, 1}]

    slopes
    |> Enum.map(&count_trees(areas, &1))
    |> Enum.reduce(1, &(&1 * &2))
  end

  def resolve_first_part(), do: get_input() |> count_trees({1, 3})
  def resolve_second_part(), do: get_input() |> multiply_trees_counts
end

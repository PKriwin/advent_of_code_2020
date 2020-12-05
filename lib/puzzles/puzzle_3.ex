defmodule AdventOfCode.Puzzle3 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  def get_input(), do: InputReader.read_input(3)

  def count_trees([_first_area | areas], _movement = {down, right}) do
    areas
    |> Enum.with_index()
    |> Enum.take_every(down)
    |> Enum.reduce(0, fn {area, index}, trees_count ->
      zone = rem(index * right + right, String.length(area))
      zone_content = area |> String.codepoints() |> Enum.at(zone)

      trees_count + if zone_content == "#", do: 1, else: 0
    end)
  end

  def resolve_first_part(), do: get_input() |> count_trees({1, 3})
end

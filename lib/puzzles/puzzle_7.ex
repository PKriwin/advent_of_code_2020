defmodule AdventOfCode.Puzzle7 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  def get_input() do
    InputReader.read_input(7)
    |> Enum.map(&String.split(&1, ~r/ bags contain /))
    |> Enum.map(fn [container_color, content] ->
      %{
        "container_color" => container_color,
        "content" =>
          if content == "no other bags." do
            []
          else
            Regex.scan(~r/(\d \w+ \w+)(?=( bag(s\.|s,|,|.)))/, content, capture: :first)
            |> Enum.map(&Regex.named_captures(~r/(?<quantity>\d) (?<color>.+)/, hd(&1)))
            |> Enum.map(fn mapping = %{"quantity" => quantity} ->
              %{mapping | "quantity" => String.to_integer(quantity)}
            end)
          end
      }
    end)
    |> Enum.reduce(%{}, fn rule, map ->
      Map.put(map, rule["container_color"], rule["content"])
    end)
  end

  def content_colors_set(rules_map, color, color_set \\ %MapSet{}) do
    rules_map[color]
    |> case do
      [] ->
        %MapSet{}

      content ->
        content
        |> Enum.reduce(color_set, fn %{"color" => new_color}, acc ->
          MapSet.put(acc, new_color)
          |> (&MapSet.union(&1, content_colors_set(rules_map, new_color, &1))).()
        end)
    end
  end

  def content_count(rules_map, color) do
    rules_map[color]
    |> case do
      [] ->
        0

      content ->
        content
        |> Enum.reduce(0, fn %{"color" => new_color, "quantity" => qty}, count ->
          count + qty + qty * content_count(rules_map, new_color)
        end)
    end
  end

  def resolve_first_part() do
    rules_map = get_input()

    rules_map
    |> Map.keys()
    |> Enum.map(&content_colors_set(rules_map, &1))
    |> Enum.count(&MapSet.member?(&1, "shiny gold"))
  end

  def resolve_second_part(), do: get_input() |> content_count("shiny gold")
end

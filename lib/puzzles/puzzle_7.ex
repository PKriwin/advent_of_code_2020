defmodule AdventOfCode.Puzzle7 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  def get_input() do
    InputReader.read_input(7)
    |> Enum.reduce(%{}, fn rule, rule_map ->
      [container_color, content] = String.split(rule, ~r/ bags contain /)

      if content == "no other bags." do
        []
      else
        Regex.scan(~r/(\d \w+ \w+)(?=( bag(s\.|s,|,|.)))/, content, capture: :first)
        |> Enum.map(&Regex.named_captures(~r/(?<quantity>\d) (?<color>.+)/, hd(&1)))
        |> Enum.map(fn mapping = %{"quantity" => quantity} ->
          %{mapping | "quantity" => String.to_integer(quantity)}
        end)
      end
      |> (&Map.put(rule_map, container_color, &1)).()
    end)
  end

  def preorder_tree_traversal(tree, node, on_empty_children, on_children) do
    tree[node]
    |> case do
      [] -> on_empty_children.()
      children -> on_children.(children)
    end
  end

  def content_colors_set(rules_map, color) do
    preorder_tree_traversal(rules_map, color, fn -> %MapSet{} end, fn children ->
      children
      |> Enum.reduce(%MapSet{}, fn %{"color" => new_color}, acc ->
        MapSet.put(acc, new_color)
        |> MapSet.union(content_colors_set(rules_map, new_color))
      end)
    end)
  end

  def content_count(rules_map, color) do
    preorder_tree_traversal(rules_map, color, fn -> [] end, fn children ->
      children
      |> Enum.reduce(0, fn %{"color" => new_color, "quantity" => qty}, count ->
        count + qty + qty * content_count(rules_map, new_color)
      end)
    end)
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

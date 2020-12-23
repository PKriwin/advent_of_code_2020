defmodule AdventOfCode.Puzzle10 do
  use AdventOfCode.Puzzle, no: 10

  def parse_input() do
    adapters = get_input() |> Enum.map(&String.to_integer/1)
    ([0] ++ adapters ++ [Enum.max(adapters) + 3]) |> Enum.sort()
  end

  def difference_map(adapters_chain) do
    adapters_chain
    |> Enum.with_index()
    |> Enum.reduce_while(%{}, fn {adapter, index}, difference_map ->
      should_continue = if index + 1 == length(adapters_chain) - 1, do: :halt, else: :cont

      {should_continue,
       Map.update(
         difference_map,
         Enum.at(adapters_chain, index + 1) - adapter,
         [index],
         &(&1 ++ [index])
       )}
    end)
  end

  def combinations_count(adapters_chain) do
    1..(length(adapters_chain) - 2)
    |> Enum.reduce({0, 1}, fn index, {consecutive_droppable_adapters, combinations_count} ->
      if Enum.at(adapters_chain, index + 1) - Enum.at(adapters_chain, index - 1) <= 3 do
        {consecutive_droppable_adapters + 1, combinations_count}
      else
        {0,
         combinations_count *
           (consecutive_droppable_adapters
            |> case do
              3 -> 7
              2 -> 4
              1 -> 2
              0 -> 1
            end)}
      end
    end)
    |> elem(1)
  end

  def resolve_first_part(),
    do: parse_input() |> difference_map |> (&(length(&1[1]) * length(&1[3]))).()

  def resolve_second_part(), do: parse_input() |> combinations_count
end

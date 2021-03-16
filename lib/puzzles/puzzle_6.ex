defmodule AdventOfCode.Puzzle6 do
  use AdventOfCode.Puzzle, no: 6

  def parse_input do
    get_input()
    |> Stream.chunk_by(&(&1 != ""))
    |> Stream.filter(&(&1 != [""]))
  end

  def affirmatives_count_per_question_for_group(group) do
    group
    |> Enum.join()
    |> String.codepoints()
    |> Enum.reduce(%{}, fn question, affirmatives_count ->
      Map.update(affirmatives_count, question, 1, &(&1 + 1))
    end)
  end

  def unanimities_count_for_group(group) do
    group
    |> affirmatives_count_per_question_for_group
    |> Stream.filter(fn {_question, affirmative_counts} -> affirmative_counts == length(group) end)
    |> Enum.count()
  end

  def resolve_first_part do
    parse_input()
    |> Stream.map(&affirmatives_count_per_question_for_group/1)
    |> Stream.map(&map_size/1)
    |> Enum.sum()
  end

  def resolve_second_part,
    do: parse_input() |> Stream.map(&unanimities_count_for_group/1) |> Enum.sum()
end

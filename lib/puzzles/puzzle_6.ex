defmodule AdventOfCode.Puzzle6 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  def get_input() do
    InputReader.read_input(6)
    |> Enum.chunk_by(&(&1 != ""))
    |> Enum.filter(&(&1 != [""]))
  end

  def affirmatives_count_per_question_for_group(group) do
    group
    |> Enum.join()
    |> String.codepoints()
    |> Enum.reduce(%{}, fn question, affirmatives_count ->
      Map.put(affirmatives_count, question, (affirmatives_count[question] || 0) + 1)
    end)
  end

  def unanimities_count_for_group(group) do
    group
    |> affirmatives_count_per_question_for_group
    |> Map.to_list()
    |> Enum.filter(fn {_question, affirmative_counts} -> affirmative_counts == length(group) end)
    |> Enum.count()
  end

  def resolve_first_part(),
    do:
      get_input()
      |> Enum.map(&affirmatives_count_per_question_for_group/1)
      |> Enum.map(&map_size/1)
      |> Enum.sum()

  def resolve_second_part(),
    do: get_input() |> Enum.map(&unanimities_count_for_group/1) |> Enum.sum()
end

defmodule AdventOfCode.Puzzle15 do
  use AdventOfCode.Puzzle, no: 15
  alias ETS.Set

  def parse_input do
    get_input()
    |> Enum.at(0)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def memory_game(start_sequence, turns_count) do
    memory = Set.new!()

    start_sequence
    |> Stream.take(length(start_sequence) - 1)
    |> Stream.with_index(1)
    |> Enum.each(&Set.put!(memory, &1))

    Stream.unfold(
      {length(start_sequence), start_sequence |> List.last()},
      fn {turn, last_spoken_nb} ->
        if turn == turns_count do
          nil
        else
          next_spoken_nb =
            case Set.get!(memory, last_spoken_nb) do
              nil -> 0
              {_, index} -> turn - index
            end

          Set.put!(memory, {last_spoken_nb, turn})
          {next_spoken_nb, {turn + 1, next_spoken_nb}}
        end
      end
    )
    |> Enum.to_list()
    |> List.last()
  end

  def resolve_first_part, do: parse_input() |> memory_game(2020)
  def resolve_second_part, do: parse_input() |> memory_game(30_000_000)
end

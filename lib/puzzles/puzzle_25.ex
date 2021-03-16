defmodule AdventOfCode.Puzzle25 do
  use AdventOfCode.Puzzle, no: 25

  @initial_subject_number 7
  @divider 20_201_227

  def parse_input,
    do: get_input() |> Stream.map(&String.to_integer/1) |> Enum.to_list() |> List.to_tuple()

  def transform(subject_number),
    do: Stream.unfold(1, fn value -> rem(value * subject_number, @divider) |> (&{&1, &1}).() end)

  def loop_size(public_key) do
    transform(@initial_subject_number)
    |> Stream.with_index()
    |> Enum.find_value(fn {value, iteration} ->
      if value == public_key, do: iteration
    end)
  end

  def encryption_key({card_public_key, door_public_key}),
    do: transform(door_public_key) |> Enum.at(loop_size(card_public_key))

  def resolve_first_part, do: parse_input() |> encryption_key
  def resolve_second_part, do: parse_input()
end

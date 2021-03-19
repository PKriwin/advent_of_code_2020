defmodule AdventOfCode.Puzzle23 do
  use AdventOfCode.Puzzle, no: 23

  def parse_input do
    get_input()
    |> Enum.at(0)
    |> String.split("")
    |> Stream.filter(&(&1 != ""))
    |> Enum.map(&String.to_integer/1)
  end

  def find_destination(rest_of_cups, current_cup) do
    rest_of_cups
    |> Enum.sort(&(&1 >= &2))
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != current_cup))
    |> Enum.at(1)
  end

  def shift_cup(cups, cup, to_index) do
    cup_index = Enum.find_index(cups, &(&1 == cup))

    if cup_index == to_index do
      cups
    else
      1..(cup_index + length(cups) - to_index)
      |> Enum.reduce(cups, fn _, [top_cup | cups_tail] ->
        cups_tail ++ [top_cup]
      end)
    end
  end

  def move(cups, times) do
    1..times
    |> Enum.reduce({cups, 0}, fn _, {cups, current_cup_index} ->
      current_cup = Enum.at(cups, current_cup_index)

      {next_current_cup, pick_up} =
        Stream.cycle(cups)
        |> Stream.drop(current_cup_index + 1)
        |> Enum.take(4)
        |> List.pop_at(-1)

      rest_of_cups = cups |> Enum.filter(&(not Enum.member?(pick_up, &1)))
      next_current_cup_index = rem(current_cup_index + 1, length(cups))
      destination = find_destination(rest_of_cups, current_cup)

      cups_with_pickup_replaced =
        rest_of_cups
        |> List.insert_at(Enum.find_index(rest_of_cups, &(&1 == destination)) + 1, pick_up)
        |> List.flatten()

      new_cups = shift_cup(cups_with_pickup_replaced, next_current_cup, next_current_cup_index)

      {new_cups, next_current_cup_index}
    end)
    |> elem(0)
  end

  def cups_after_label(cups, label \\ 1) do
    {suite_tail, [^label | suite_head]} = Enum.split_while(cups, &(&1 != label))
    suite_head ++ suite_tail
  end

  def resolve_first_part, do: parse_input() |> move(100) |> cups_after_label
  def resolve_second_part, do: parse_input()
end

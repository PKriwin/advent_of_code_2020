defmodule AdventOfCode.Puzzle13 do
  use AdventOfCode.Puzzle, no: 13

  def parse_input() do
    [depart_timestamp, bus_schedule] = get_input() |> Enum.take(2)

    {String.to_integer(depart_timestamp),
     bus_schedule
     |> String.split(",")
     |> Stream.with_index()
     |> Stream.filter(&(elem(&1, 0) != "x"))
     |> Enum.map(&{elem(&1, 1), String.to_integer(elem(&1, 0))})}
  end

  def earliest_departure(ideal_departure, bus_ids) do
    bus_ids
    |> Enum.map(&{&1, div(ideal_departure, &1) * &1 + &1})
    |> Enum.min_by(&elem(&1, 1))
  end

  def resolve_first_part() do
    {ideal_departure, bus_schedule} = parse_input()
    bus_ids = bus_schedule |> Enum.map(&elem(&1, 1))
    {bus_id, earliest_departure} = earliest_departure(ideal_departure, bus_ids)
    time_to_wait = earliest_departure - ideal_departure

    bus_id * time_to_wait
  end

  def resolve_second_part(), do: parse_input()
end

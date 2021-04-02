defmodule AdventOfCode.Puzzle13 do
  use AdventOfCode.Puzzle, no: 13

  def parse_input do
    [depart_timestamp, bus_schedule] = get_input() |> Enum.take(2)

    {String.to_integer(depart_timestamp),
     bus_schedule
     |> String.split(",")
     |> Stream.with_index()
     |> Stream.filter(&(elem(&1, 0) != "x"))
     |> Enum.map(&{elem(&1, 1), String.to_integer(elem(&1, 0))})}
  end

  def chinese_remainder(rems, mods) do
    big_n = Enum.reduce(mods, 1, &(&1 * &2))
    nis = Enum.map(mods, &div(big_n, &1))
    nis_inv = Enum.zip(nis, mods) |> Enum.map(fn {ni, mod} -> Math.mod_inv!(ni, mod) end)

    x =
      Enum.zip([rems, nis, nis_inv])
      |> Enum.reduce(0, fn {r, ni, ni_inv}, sum ->
        sum + r * ni * ni_inv
      end)

    rem(x, big_n)
  end

  def earliest_departure(ideal_departure, bus_ids) do
    bus_ids
    |> Enum.map(&{&1, div(ideal_departure, &1) * &1 + &1})
    |> Enum.min_by(&elem(&1, 1))
  end

  def resolve_first_part do
    {ideal_departure, bus_schedule} = parse_input()
    bus_ids = bus_schedule |> Enum.map(&elem(&1, 1))
    {bus_id, earliest_departure} = earliest_departure(ideal_departure, bus_ids)
    time_to_wait = earliest_departure - ideal_departure

    bus_id * time_to_wait
  end

  def resolve_second_part do
    {_, bus_schedule} = parse_input()
    mods = Enum.map(bus_schedule, &elem(&1, 1))
    rems = [0 | Enum.drop(bus_schedule, 1) |> Enum.map(fn {pos, nb} -> nb - pos end)]

    chinese_remainder(rems, mods)
  end
end

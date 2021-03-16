defmodule AdventOfCode.Puzzle11 do
  use AdventOfCode.Puzzle, no: 11
  alias ETS.Set

  @directions [:down, :up, :right, :left, :down_right, :up_left, :down_left, :up_right]

  def parse_input do
    seats_map = Set.new!(protection: :public)

    get_input()
    |> Stream.map(&String.codepoints/1)
    |> Stream.with_index()
    |> Enum.flat_map(fn {row_content, row_index} ->
      row_content
      |> Stream.with_index()
      |> Enum.map(fn {column_content, col_index} ->
        {{row_index, col_index},
         case column_content do
           "L" -> :empty_seat
           "#" -> :filled_seat
           "." -> :floor
         end}
      end)
    end)
    |> (&Set.put!(seats_map, &1)).()

    seats_map
  end

  def filled_seats_count(seats_map), do: Set.match!(seats_map, {:"$1", :filled_seat}) |> length

  def relative_position({row, col}, direction, offset) do
    case direction do
      :down -> {row + offset, col}
      :up -> {row - offset, col}
      :right -> {row, col + offset}
      :left -> {row, col - offset}
      :down_right -> {row + offset, col + offset}
      :up_left -> {row - offset, col - offset}
      :down_left -> {row + offset, col - offset}
      :up_right -> {row - offset, col + offset}
    end
  end

  def filled_adjacent_seats_count(seats_map, cell) do
    Set.select!(
      seats_map,
      @directions |> Enum.map(&{{relative_position(cell, &1, 1), :_}, [], [:"$_"]})
    )
    |> Enum.count(fn {_, seat} -> seat == :filled_seat end)
  end

  def filled_on_sight_seats_count(seats_map, cell_position) do
    @directions
    |> Enum.map(fn direction ->
      Stream.unfold(1, fn offset ->
        case Set.get!(seats_map, relative_position(cell_position, direction, offset)) do
          {_, cell_content} -> {cell_content, offset + 1}
          nil -> nil
        end
      end)
      |> Enum.find(&(&1 == :filled_seat or &1 == :empty_seat))
      |> case do
        :filled_seat -> 1
        _ -> 0
      end
    end)
    |> Enum.sum()
  end

  def seat_rule(
        seats_map,
        {cell_position, fill_value},
        count_surrounding_filled_seats,
        filled_seats_count_tolerance
      ) do
    filled_surrounding_seats_count = count_surrounding_filled_seats.(seats_map, cell_position)

    case fill_value do
      :empty_seat when filled_surrounding_seats_count == 0 ->
        :filled_seat

      :filled_seat when filled_surrounding_seats_count >= filled_seats_count_tolerance ->
        :empty_seat

      _ ->
        fill_value
    end
  end

  def apply_seats_rule_until_stable_state(seats_map, rule) do
    actual_seats_count = filled_seats_count(seats_map)

    Set.to_list!(seats_map)
    |> Flow.from_enumerable()
    |> Flow.map(fn {cell_position, cell_value} = cell ->
      if cell_value == :floor do
        cell
      else
        {cell_position, rule.(seats_map, cell)}
      end
    end)
    |> Flow.partition()
    |> Enum.to_list()
    |> (&Set.put(seats_map, &1)).()

    if filled_seats_count(seats_map) != actual_seats_count do
      apply_seats_rule_until_stable_state(seats_map, rule)
    end
  end

  def count_filled_seats_at_stable_state(
        count_surrounding_filled_seats,
        filled_seats_count_tolerance
      ) do
    seats_map = parse_input()

    apply_seats_rule_until_stable_state(seats_map, fn seats_map, cell ->
      seat_rule(seats_map, cell, count_surrounding_filled_seats, filled_seats_count_tolerance)
    end)

    filled_seats_count(seats_map)
  end

  def resolve_first_part,
    do: count_filled_seats_at_stable_state(&filled_adjacent_seats_count/2, 4)

  def resolve_second_part,
    do: count_filled_seats_at_stable_state(&filled_on_sight_seats_count/2, 5)
end

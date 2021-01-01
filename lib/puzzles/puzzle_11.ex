defmodule AdventOfCode.Puzzle11 do
  use AdventOfCode.Puzzle, no: 11

  @directions [:down, :up, :right, :left, :down_right, :up_left, :down_left, :up_right]

  def parse_input() do
    if :ets.whereis(:seats_map) == :undefined do
      :ets.new(:seats_map, [:named_table, :set, :public])
    end

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
    |> (&:ets.insert(:seats_map, &1)).()
  end

  def filled_seats_count(), do: :ets.match(:seats_map, {:"$1", :filled_seat}) |> length

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

  def filled_adjacent_seats_count(cell) do
    :ets.select(
      :seats_map,
      @directions |> Enum.map(&{{relative_position(cell, &1, 1), :_}, [], [:"$_"]})
    )
    |> Enum.count(fn {_, seat} -> seat == :filled_seat end)
  end

  def filled_on_sight_seats_count(cell_position) do
    @directions
    |> Enum.map(fn direction ->
      Stream.unfold(1, fn offset ->
        case :ets.lookup(:seats_map, relative_position(cell_position, direction, offset)) do
          [{_, cell_content}] -> {cell_content, offset + 1}
          [] -> nil
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
        {cell_position, fill_value},
        count_surrounding_filled_seats,
        filled_seats_count_tolerance
      ) do
    filled_surrounding_seats_count = count_surrounding_filled_seats.(cell_position)

    case fill_value do
      :empty_seat when filled_surrounding_seats_count == 0 ->
        :filled_seat

      :filled_seat when filled_surrounding_seats_count >= filled_seats_count_tolerance ->
        :empty_seat

      _ ->
        fill_value
    end
  end

  def apply_seats_rule_until_stable_state(rule) do
    actual_seats_count = filled_seats_count()

    :ets.tab2list(:seats_map)
    |> Flow.from_enumerable()
    |> Flow.map(fn {cell_position, cell_value} = cell ->
      if cell_value == :floor do
        cell
      else
        {cell_position, rule.(cell)}
      end
    end)
    |> Flow.partition()
    |> Enum.to_list()
    |> (&:ets.insert(:seats_map, &1)).()

    if filled_seats_count() != actual_seats_count do
      apply_seats_rule_until_stable_state(rule)
    end
  end

  def resolve_first_part() do
    parse_input()

    apply_seats_rule_until_stable_state(fn cell ->
      seat_rule(cell, &filled_adjacent_seats_count/1, 4)
    end)

    filled_seats_count()
  end

  def resolve_second_part() do
    parse_input()

    apply_seats_rule_until_stable_state(fn cell ->
      seat_rule(cell, &filled_on_sight_seats_count/1, 5)
    end)

    filled_seats_count()
  end
end

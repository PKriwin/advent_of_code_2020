defmodule AdventOfCode.Puzzle11 do
  use AdventOfCode.Puzzle, no: 11

  def to_cell_content(seat) do
    case seat do
      "L" -> :empty_seat
      "#" -> :filled_seat
      "." -> :floor
    end
  end

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
        {{row_index, col_index}, to_cell_content(column_content)}
      end)
    end)
    |> (&:ets.insert(:seats_map, &1)).()
  end

  def adjacent_cells({row, col}) do
    adjacent_positions = [
      {row + 1, col},
      {row - 1, col},
      {row, col + 1},
      {row, col - 1},
      {row + 1, col + 1},
      {row - 1, col - 1},
      {row + 1, col - 1},
      {row - 1, col + 1}
    ]

    :ets.select(
      :seats_map,
      for(position <- adjacent_positions, do: {{position, :_}, [], [:"$_"]})
    )
  end

  def filled_seats_count(), do: :ets.match(:seats_map, {:"$1", :filled_seat}) |> length

  def apply_rule_for_seat({seat_position, fill_value}) do
    filled_adjacent_cells_count =
      adjacent_cells(seat_position)
      |> Enum.count(fn {_, seat} -> seat == :filled_seat end)

    case fill_value do
      :empty_seat when filled_adjacent_cells_count == 0 -> :filled_seat
      :filled_seat when filled_adjacent_cells_count >= 4 -> :empty_seat
      _ -> fill_value
    end
  end

  def apply_seat_rules() do
    :ets.tab2list(:seats_map)
    |> Flow.from_enumerable()
    |> Flow.map(fn {cell_position, cell_value} = cell ->
      if cell_value == :floor do
        cell
      else
        {cell_position, apply_rule_for_seat(cell)}
      end
    end)
    |> Flow.partition()
    |> Enum.to_list()
    |> (&:ets.insert(:seats_map, &1)).()
  end

  def apply_seat_rules_until_stable_state() do
    actual_seats_count = filled_seats_count()
    apply_seat_rules()

    if filled_seats_count() != actual_seats_count do
      apply_seat_rules_until_stable_state()
    end
  end

  def resolve_first_part() do
    parse_input()
    apply_seat_rules_until_stable_state()
    filled_seats_count()
  end

  def resolve_second_part(), do: parse_input()
end

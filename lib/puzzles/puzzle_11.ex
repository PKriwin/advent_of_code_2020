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
    get_input()
    |> Stream.map(&String.codepoints/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {row_content, row_index}, seat_map ->
      row_content
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {column_content, col_index}, row_seat_map ->
        Map.put(row_seat_map, {row_index, col_index}, to_cell_content(column_content))
      end)
      |> Map.merge(seat_map)
    end)
  end

  def adjacent_cells(seats_map, {row, col}) do
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

    adjacent_positions
    |> Stream.map(&{&1, seats_map[&1]})
    |> Stream.filter(&(elem(&1, 1) != nil))
    |> Enum.reduce(%{}, &Map.put(&2, elem(&1, 0), elem(&1, 1)))
  end

  def count_filled_seats(seats_map),
    do:
      seats_map
      |> Map.to_list()
      |> Stream.filter(fn {_, seat} -> seat == :filled_seat end)
      |> Enum.count()

  def apply_seat_rules(seats_map) do
    seats_map
    |> Map.to_list()
    |> Enum.reduce(%{}, fn {cell_position, cell_value}, new_seats_map ->
      filled_adjacent_cells_count = adjacent_cells(seats_map, cell_position) |> count_filled_seats

      Map.put(
        new_seats_map,
        cell_position,
        cond do
          cell_value == :empty_seat and filled_adjacent_cells_count == 0 -> :filled_seat
          cell_value == :filled_seat and filled_adjacent_cells_count >= 4 -> :empty_seat
          cell_value == :floor -> :floor
          true -> cell_value
        end
      )
    end)
  end

  def to_stable_state(seats_map, filled_seats_count \\ 0) do
    new_seats_map = apply_seat_rules(seats_map)

    case count_filled_seats(new_seats_map) do
      ^filled_seats_count -> {new_seats_map, filled_seats_count}
      new_seat_count -> to_stable_state(new_seats_map, new_seat_count)
    end
  end

  def resolve_first_part(), do: parse_input() |> to_stable_state() |> elem(1)
  def resolve_second_part(), do: parse_input()
end

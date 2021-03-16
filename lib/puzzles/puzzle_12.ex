defmodule AdventOfCode.Puzzle12 do
  use AdventOfCode.Puzzle, no: 12

  @cardinal_directions [:north, :east, :south, :west]
  @rotations [:left, :right]

  def parse_input do
    get_input()
    |> Stream.map(fn direction_and_value ->
      {direction, value} = String.split_at(direction_and_value, 1)

      {case direction do
         "N" -> :north
         "S" -> :south
         "E" -> :east
         "W" -> :west
         "L" -> :left
         "R" -> :right
         "F" -> :forward
       end, String.to_integer(value)}
    end)
  end

  def move_position({x, y}, direction, value) do
    case direction do
      :north -> {x, y + value}
      :south -> {x, y - value}
      :west -> {x - value, y}
      :east -> {x + value, y}
    end
  end

  def move_boat_to_direction(
        %{orientation: orientation, position: position} = boat_state,
        direction,
        value
      ) do
    case direction do
      :forward ->
        move_boat_to_direction(boat_state, orientation, value)

      direction ->
        move_position(position, direction, value) |> (&Map.put(boat_state, :position, &1)).()
    end
  end

  def rotate_boat(%{orientation: orientation} = boat_position, direction, value) do
    rotation_cycle =
      case direction do
        :right -> [:north, :east, :south, :west]
        :left -> [:north, :west, :south, :east]
      end

    turn_count = abs(div(value, 90))
    offset = rotation_cycle |> Enum.find_index(&(&1 == orientation))

    Map.put(
      boat_position,
      :orientation,
      Stream.cycle(rotation_cycle)
      |> Enum.at(turn_count + offset)
    )
  end

  def rotate_waypoint_around_boat(
        {waypoint_x, waypoint_y},
        {boat_position_x, boat_position_y},
        direction,
        value
      ) do
    angle =
      case direction do
        :left -> value
        :right -> -value
      end

    {waypoint_as_position_x, waypoint_as_position_y} =
      {boat_position_x + waypoint_x, boat_position_y + waypoint_y}

    {boat_position_x + Math.cos(Math.deg2rad(angle)) * (waypoint_as_position_x - boat_position_x) -
       Math.sin(Math.deg2rad(angle)) * (waypoint_as_position_y - boat_position_y) -
       boat_position_x,
     boat_position_y + Math.sin(Math.deg2rad(angle)) * (waypoint_as_position_x - boat_position_x) +
       Math.cos(Math.deg2rad(angle)) * (waypoint_as_position_y - boat_position_y) -
       boat_position_y}
  end

  def move_boat_to_waypoint({boat_position_x, boat_position_y}, {offset_x, offset_y}, times),
    do: {boat_position_x + offset_x * times, boat_position_y + offset_y * times}

  def move_boat_absolute(
        instructions,
        initial_boat_state \\ %{orientation: :east, position: {0, 0}}
      ) do
    instructions
    |> Enum.reduce(initial_boat_state, fn {direction, value}, boat_state ->
      cond do
        Enum.member?([:forward | @cardinal_directions], direction) ->
          move_boat_to_direction(boat_state, direction, value)

        Enum.member?(@rotations, direction) ->
          rotate_boat(boat_state, direction, value)
      end
    end)
  end

  def move_boat_with_waypoint(
        instructions,
        initial_boat_position \\ {0, 0},
        initial_waypoint \\ {10, 1}
      ) do
    instructions
    |> Enum.reduce({initial_boat_position, initial_waypoint}, fn {direction, value},
                                                                 {boat_position, waypoint} ->
      cond do
        direction == :forward ->
          {move_boat_to_waypoint(boat_position, waypoint, value), waypoint}

        Enum.member?(@cardinal_directions, direction) ->
          {boat_position, move_position(waypoint, direction, value)}

        Enum.member?(@rotations, direction) ->
          {boat_position, rotate_waypoint_around_boat(waypoint, boat_position, direction, value)}
      end
    end)
  end

  def manhattan_distance({x, y}), do: abs(x) + abs(y)

  def resolve_first_part,
    do: parse_input() |> move_boat_absolute |> (&manhattan_distance(&1[:position])).()

  def resolve_second_part,
    do: parse_input() |> move_boat_with_waypoint |> (&manhattan_distance(elem(&1, 0))).()
end

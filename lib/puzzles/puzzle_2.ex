defmodule AdventOfCode.Puzzle2 do
  use AdventOfCode.Puzzle, no: 2

  def parse_input do
    get_input()
    |> Enum.map(fn line ->
      [policy, password] = String.split(line, ":")
      [range, letter] = String.split(policy, " ")
      [min, max] = String.split(range, "-")

      {
        %{
          "min" => String.to_integer(min),
          "max" => String.to_integer(max),
          "letter" => letter
        },
        String.trim(password)
      }
    end)
  end

  def letters_count({%{"min" => min_count, "max" => max_count, "letter" => letter}, password}) do
    count = password |> String.codepoints() |> Enum.count(&(&1 == letter))
    count >= min_count and count <= max_count
  end

  def letters_positions(
        {%{"min" => min_position, "max" => max_position, "letter" => letter}, password}
      ) do
    password_letters = String.codepoints(password)
    min_postion_set = Enum.at(password_letters, min_position - 1) == letter
    max_postion_set = Enum.at(password_letters, max_position - 1) == letter

    (!min_postion_set and max_postion_set) or (min_postion_set and !max_postion_set)
  end

  def count_valid_passwords(input, policy), do: input |> Enum.count(&policy.(&1))
  def resolve_first_part, do: parse_input() |> count_valid_passwords(&letters_count/1)
  def resolve_second_part, do: parse_input() |> count_valid_passwords(&letters_positions/1)
end

defmodule AdventOfCode.Puzzle2 do
  alias AdventOfCode.{Utils}
  alias Utils.{InputReader}

  def parse_input_line(line) do
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
  end

  def get_input() do
    InputReader.read_input(2) |> Enum.map(&parse_input_line/1)
  end

  def count_letter_occurrence(word, letter) do
    word
    |> String.codepoints()
    |> Enum.filter(&(&1 == letter))
    |> Enum.count()
  end

  def letters_count({%{"min" => min_count, "max" => max_count, "letter" => letter}, password}) do
    count = count_letter_occurrence(password, letter)
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

  def count_valid_passwords(input, policy), do: input |> Enum.filter(&policy.(&1)) |> Enum.count()

  def resolve_first_part(), do: get_input() |> count_valid_passwords(&letters_count/1)
  def resolve_second_part(), do: get_input() |> count_valid_passwords(&letters_positions/1)
end

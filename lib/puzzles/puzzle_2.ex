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
      password
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

  def pasword_is_valid({%{"min" => min, "max" => max, "letter" => letter}, password}) do
    count = count_letter_occurrence(password, letter)
    count >= min && count <= max
  end

  def count_valid_passwords(input), do: input |> Enum.filter(&pasword_is_valid/1) |> Enum.count()

  def resolve_first_part(), do: Utils.resolve_puzzle(&get_input/0, &count_valid_passwords/1)
end

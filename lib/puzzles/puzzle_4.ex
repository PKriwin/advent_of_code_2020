defmodule AdventOfCode.Puzzle4 do
  use AdventOfCode.Puzzle, no: 4

  def parse_input() do
    get_input()
    |> Stream.chunk_by(&(&1 != ""))
    |> Stream.filter(&(&1 != [""]))
    |> Stream.map(&Enum.join(&1, " "))
    |> Stream.map(fn input_line ->
      String.split(input_line, " ")
      |> Enum.reduce(%{}, fn key_value, passport ->
        [key, value] = String.split(key_value, ":")
        Map.put(passport, key, value)
      end)
    end)
  end

  def has_required_fields(passport) do
    required_fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

    Enum.all?(required_fields, &Map.has_key?(passport, &1))
  end

  def is_in_range(value, min, max), do: value >= min && value <= max

  def valid_field_values(passport) do
    validators = [
      &has_required_fields/1,
      fn %{"byr" => byr} -> is_in_range(String.to_integer(byr), 1920, 2002) end,
      fn %{"iyr" => iyr} -> is_in_range(String.to_integer(iyr), 2010, 2020) end,
      fn %{"eyr" => eyr} -> is_in_range(String.to_integer(eyr), 2020, 2030) end,
      fn %{"hgt" => hgt} ->
        String.match?(hgt, ~r/^(\d{2}in)|(\d{3}cm)$/iu) &&
          String.split_at(hgt, -2)
          |> case do
            {value, "cm"} -> is_in_range(String.to_integer(value), 150, 193)
            {value, "in"} -> is_in_range(String.to_integer(value), 59, 76)
          end
      end,
      fn %{"hcl" => hcl} -> String.match?(hcl, ~r/^#[0-9a-f]{6}$/iu) end,
      fn %{"ecl" => ecl} ->
        Enum.member?(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], ecl)
      end,
      fn %{"pid" => pid} -> String.match?(pid, ~r/^[0-9]{9}$/iu) end
    ]

    Enum.all?(validators, & &1.(passport))
  end

  def count_valid_passports(input, policy), do: input |> Enum.count(&policy.(&1))

  def resolve_first_part(), do: parse_input() |> count_valid_passports(&has_required_fields/1)
  def resolve_second_part(), do: parse_input() |> count_valid_passports(&valid_field_values/1)
end

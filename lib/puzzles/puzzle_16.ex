defmodule AdventOfCode.Puzzle16 do
  use AdventOfCode.Puzzle, no: 16

  def parse_input() do
    data = get_input() |> Enum.to_list()

    %{
      validation_rules:
        data
        |> Enum.slice(0..19)
        |> Enum.reduce(%{}, fn rule, rules_map ->
          %{
            "rule_name" => rule_name,
            "range1_lb" => range1_lb,
            "range1_ub" => range1_ub,
            "range2_lb" => range2_lb,
            "range2_ub" => range2_ub
          } =
            ~r/^(?<rule_name>.+): (?<range1_lb>\d+)-(?<range1_ub>\d+) or (?<range2_lb>\d+)-(?<range2_ub>\d+)$/
            |> Regex.named_captures(rule)

          rules_map
          |> Map.merge(%{
            rule_name => {
              {String.to_integer(range1_lb), String.to_integer(range1_ub)},
              {String.to_integer(range2_lb), String.to_integer(range2_ub)}
            }
          })
        end),
      current_ticket: data |> Enum.at(22) |> String.split(",") |> Enum.map(&String.to_integer/1),
      nearby_tickets:
        data
        |> Enum.slice(25..266)
        |> Enum.map(fn ticket -> String.split(ticket, ",") |> Enum.map(&String.to_integer/1) end)
    }
  end

  def in_range?(value, {min, max}), do: value >= min && value <= max

  def valid?(ticket_field, validation_rules) do
    Enum.any?(validation_rules, fn {_, {range1, range2}} ->
      in_range?(ticket_field, range1) or in_range?(ticket_field, range2)
    end)
  end

  def error_rate(%{validation_rules: validation_rules, nearby_tickets: nearby_tickets}) do
    nearby_tickets
    |> Stream.flat_map(& &1)
    |> Stream.filter(&(not valid?(&1, validation_rules)))
    |> Enum.sum()
  end

  def ticket_fields_order(%{validation_rules: validation_rules, nearby_tickets: nearby_tickets}) do
    valid_nearby_tickets =
      nearby_tickets
      |> Stream.filter(fn ticket_fields ->
        ticket_fields |> Enum.all?(&valid?(&1, validation_rules))
      end)
  end

  def resolve_first_part(), do: parse_input() |> error_rate()
  def resolve_second_part(), do: parse_input() |> ticket_fields_order()
end

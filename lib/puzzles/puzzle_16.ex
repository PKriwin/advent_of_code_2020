defmodule AdventOfCode.Puzzle16 do
  use AdventOfCode.Puzzle, no: 16

  def parse_input do
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

    field_groups =
      0..(map_size(validation_rules) - 1)
      |> Enum.map(fn index -> valid_nearby_tickets |> Enum.map(&Enum.at(&1, index)) end)

    potential_rules_for_field_groups =
      field_groups
      |> Stream.with_index()
      |> Enum.map(fn {field_group, index} ->
        {index,
         validation_rules
         |> Stream.filter(fn rule -> Enum.all?(field_group, &valid?(&1, [rule])) end)
         |> Enum.map(&elem(&1, 0))}
      end)

    potential_rules_for_field_groups
    |> Stream.unfold(fn potential_rules_for_field_groups ->
      case potential_rules_for_field_groups |> Enum.find(&(length(elem(&1, 1)) == 1)) do
        nil ->
          nil

        {index, [rule]} ->
          {{index, rule},
           potential_rules_for_field_groups
           |> Enum.map(fn {index, rules} ->
             {index, rules |> Enum.reject(&(&1 == rule))}
           end)}
      end
    end)
    |> Map.new()
    |> Stream.map(&elem(&1, 1))
  end

  def resolve_first_part, do: parse_input() |> error_rate()

  def resolve_second_part do
    raw_data = parse_input()

    Stream.zip(ticket_fields_order(raw_data), raw_data[:current_ticket])
    |> Stream.filter(fn {field_name, _} -> String.contains?(field_name, "departure") end)
    |> Enum.reduce(1, &(elem(&1, 1) * &2))
  end
end

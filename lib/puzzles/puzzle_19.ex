defmodule AdventOfCode.Puzzle19 do
  use AdventOfCode.Puzzle, no: 19

  def parse_input do
    {rules, messages} = get_input() |> Enum.split(131)

    rules_map =
      rules
      |> Enum.reduce(%{}, fn rule, rules_map ->
        [rule_key, rule_expr_raw] = String.split(rule, ": ")

        rule_expr =
          rule_expr_raw
          |> String.split(" ")

        Map.put(rules_map, rule_key, rule_expr)
      end)

    {messages, rules_map}
  end

  def to_regex(rules_map), do: to_regex(rules_map, Map.get(rules_map, "0"), "")
  def to_regex(_rules_map, [], regex_str), do: Regex.compile!("^#{regex_str}$")

  def to_regex(rules_map, [token | tokens_queue], regex_str) do
    if Enum.member?(["a", "b", "(", ")", "|"], token) do
      to_regex(rules_map, tokens_queue, regex_str <> token)
    else
      to_regex(
        rules_map,
        Map.get(rules_map, token) ++ [")" | tokens_queue],
        regex_str <> "("
      )
    end
  end

  def resolve_first_part do
    {messages, rules_map} = parse_input()
    rules_regex = to_regex(rules_map)

    Enum.count(messages, &Regex.match?(rules_regex, &1))
  end

  def resolve_second_part, do: parse_input()
end

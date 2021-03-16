defmodule AdventOfCode.Puzzle18 do
  use AdventOfCode.Puzzle, no: 18

  @operators ~w(add substract multiply)a
  @parenthesis ~w(l_parenthesis r_parenthesis)a

  def parse_input do
    get_input()
    |> Stream.map(fn expression ->
      String.split(expression, "")
      |> Stream.filter(&(&1 != "" and &1 != " "))
      |> Enum.map(fn
        "(" -> :l_parenthesis
        ")" -> :r_parenthesis
        "+" -> :add
        "-" -> :substract
        "*" -> :multiply
        number -> String.to_integer(number)
      end)
    end)
  end

  def eval(left_operand, operator, right_operand) do
    operation =
      case operator do
        :add -> &Kernel.+/2
        :substract -> &Kernel.-/2
        :multiply -> &Kernel.*/2
      end

    operation.(left_operand, right_operand)
  end

  def postfix_eval(tokens) do
    tokens
    |> Enum.reduce([], fn
      token, stack when is_number(token) ->
        [token | stack]

      operator, [right_operand, left_operand | stack] ->
        [eval(left_operand, operator, right_operand) | stack]
    end)
    |> hd()
  end

  def infix_to_postfix(tokens) do
    tokens
    |> Enum.reduce({[], []}, fn
      token, {queue, stack} when is_number(token) ->
        {queue ++ [token], stack}

      token, {queue, stack} when token == :r_parenthesis ->
        {to_enqueue, [:l_parenthesis | stack]} = Enum.split_while(stack, &(&1 != :l_parenthesis))
        {queue ++ to_enqueue, stack}

      token, {queue, [stack_top | stack]} when token in @operators and stack_top in @operators ->
        {queue ++ [stack_top], [token | stack]}

      token, {queue, stack} ->
        {queue, [token | stack]}
    end)
    |> Tuple.to_list()
    |> Enum.concat()
  end

  def resolve_first_part do
    parse_input()
    |> Stream.map(&infix_to_postfix/1)
    |> Stream.map(&postfix_eval/1)
    |> Enum.sum()
  end

  def resolve_second_part, do: parse_input()
end

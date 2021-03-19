defmodule AdventOfCode.Puzzle18 do
  use AdventOfCode.Puzzle, no: 18

  @operators ~w(add multiply)a

  def parse_input do
    get_input()
    |> Stream.map(fn expression ->
      String.split(expression, "")
      |> Stream.filter(&(&1 != "" and &1 != " "))
      |> Enum.map(fn
        "(" -> :l_parenthesis
        ")" -> :r_parenthesis
        "+" -> :add
        "*" -> :multiply
        number -> String.to_integer(number)
      end)
    end)
  end

  def eval(left_operand, operator, right_operand) do
    operation =
      case operator do
        :add -> &Kernel.+/2
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

  def infix_to_postfix(tokens, addition_has_higher_precedence \\ false) do
    tokens
    |> Enum.reduce({[], []}, fn
      token, {queue, stack} when is_number(token) ->
        {queue ++ [token], stack}

      :r_parenthesis, {queue, stack} ->
        {to_enqueue, [:l_parenthesis | stack_tail]} =
          Enum.split_while(stack, &(&1 != :l_parenthesis))

        {queue ++ to_enqueue, stack_tail}

      token, {queue, [stack_top | _] = stack}
      when token in @operators and stack_top in @operators and addition_has_higher_precedence ->
        if token == :multiply and stack_top == :add do
          {to_enqueue, new_stack_tail} = Enum.split_while(stack, &(&1 == :add))
          {queue ++ to_enqueue, [token | new_stack_tail]}
        else
          {queue, [token | stack]}
        end

      token, {queue, [stack_top | stack_tail]}
      when token in @operators and stack_top in @operators ->
        {queue ++ [stack_top], [token | stack_tail]}

      token, {queue, stack} ->
        {queue, [token | stack]}
    end)
    |> Tuple.to_list()
    |> Enum.concat()
  end

  def sum_all_expression(expressions, addition_has_higher_precedence \\ false) do
    expressions
    |> Stream.map(&infix_to_postfix(&1, addition_has_higher_precedence))
    |> Stream.map(&postfix_eval/1)
    |> Enum.sum()
  end

  def resolve_first_part, do: parse_input() |> sum_all_expression()
  def resolve_second_part, do: parse_input() |> sum_all_expression(true)
end

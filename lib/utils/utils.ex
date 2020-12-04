defmodule AdventOfCode.Utils do
  def resolve_puzzle(get_input, resolver), do: get_input.() |> resolver.() |> IO.puts()
end

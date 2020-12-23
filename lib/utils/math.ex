defmodule AdventOfCode.Utils.Math do
  def factorial(n), do: factorial_of(n, 1)
  defp factorial_of(0, acc), do: acc
  defp factorial_of(n, acc) when n > 0, do: factorial_of(n - 1, n * acc)

  def number_of_subsets(set_size) do
    Bitwise.bsl(1, set_size)
  end

  def pow(n, k), do: pow(n, k, 1)
  defp pow(_, 0, acc), do: acc
  defp pow(n, k, acc), do: pow(n, k - 1, n * acc)
end

defmodule AdventOfCode do
  alias AdventOfCode.{Puzzle1, Puzzle2, Puzzle3, Puzzle4, Puzzle5, Puzzle6, Puzzle7}

  def show_solutions do
    puzzles = [Puzzle1, Puzzle2, Puzzle3, Puzzle4, Puzzle5, Puzzle6, Puzzle7]

    puzzles
    |> Enum.with_index(1)
    |> Enum.each(fn {puzzle, index} ->
      IO.puts("Solution for puzzle #{index}:")
      IO.puts("Part 1: #{puzzle.resolve_first_part()}")
      IO.puts("Part 2: #{puzzle.resolve_second_part()}")
    end)
  end
end

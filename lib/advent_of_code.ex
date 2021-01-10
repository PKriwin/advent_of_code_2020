defmodule AdventOfCode do
  def show_solutions do
    puzzles = [
      AdventOfCode.Puzzle1,
      AdventOfCode.Puzzle2,
      AdventOfCode.Puzzle3,
      AdventOfCode.Puzzle4,
      AdventOfCode.Puzzle5,
      AdventOfCode.Puzzle6,
      AdventOfCode.Puzzle7,
      AdventOfCode.Puzzle8,
      AdventOfCode.Puzzle9,
      AdventOfCode.Puzzle10,
      AdventOfCode.Puzzle11,
      AdventOfCode.Puzzle12,
      AdventOfCode.Puzzle13,
      AdventOfCode.Puzzle14
    ]

    puzzles
    |> Enum.with_index(1)
    |> Enum.each(fn {puzzle, index} ->
      IO.puts("Solution for puzzle #{index}:")
      IO.puts("Part 1: #{puzzle.resolve_first_part()}")
      IO.puts("Part 2: #{puzzle.resolve_second_part()}")
    end)
  end
end

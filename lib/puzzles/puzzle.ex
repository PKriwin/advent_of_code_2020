defmodule AdventOfCode.Puzzle do
  @callback resolve_first_part() :: any()
  @callback resolve_second_part() :: any()
  @callback get_input() :: any()

  defmacro __using__(no: no) do
    quote do
      def get_input() do
        Path.join([:code.priv_dir(:advent_of_code), "inputs", "puzzle_#{unquote(no)}.txt"])
        |> File.stream!()
        |> Stream.map(&String.trim/1)
      end
    end
  end
end

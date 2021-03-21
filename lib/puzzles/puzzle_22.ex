defmodule AdventOfCode.Puzzle22 do
  use AdventOfCode.Puzzle, no: 22

  def parse_input do
    get_input()
    |> Enum.filter(&Regex.match?(~r{^\d+$}, &1))
    |> Enum.map(&String.to_integer/1)
    |> Enum.split(25)
  end

  def score(deck) do
    deck
    |> Enum.reverse()
    |> Stream.with_index(1)
    |> Enum.reduce(0, fn {points, coef}, score -> score + points * coef end)
  end

  def play_combat(deck1, deck2) do
    case [deck1, deck2] do
      [[card1 | deck1], [card2 | deck2]] ->
        cond do
          card1 > card2 -> play_combat(deck1 ++ [card1, card2], deck2)
          card1 < card2 -> play_combat(deck1, deck2 ++ [card2, card1])
        end

      decks ->
        decks |> Enum.find(&(length(&1) != 0)) |> score()
    end
  end

  def play_recursive_combat(deck1, deck2) do
  end

  def resolve_first_part, do: parse_input() |> (&play_combat(elem(&1, 0), elem(&1, 1))).()

  def resolve_second_part do
    parse_input() |> (&play_recursive_combat(elem(&1, 0), elem(&1, 1))).()
  end
end

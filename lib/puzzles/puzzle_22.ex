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

  def play_combat(decks) do
    case decks do
      {[card1 | deck1], [card2 | deck2]} ->
        cond do
          card1 > card2 -> play_combat({deck1 ++ [card1, card2], deck2})
          card1 < card2 -> play_combat({deck1, deck2 ++ [card2, card1]})
        end

      {deck1, []} ->
        {:player1, deck1}

      {[], deck2} ->
        {:player2, deck2}
    end
  end

  def play_recursive_combat(decks, mem \\ %MapSet{})
  def play_recursive_combat({deck1, []}, _mem), do: {:player1, deck1}
  def play_recursive_combat({[], deck2}, _mem), do: {:player2, deck2}

  def play_recursive_combat(decks, mem) do
    if MapSet.member?(mem, decks) do
      {:player1, elem(decks, 0)}
    else
      {[card1 | deck1], [card2 | deck2]} = decks

      if length(deck1) >= card1 and length(deck2) >= card2 do
        play_recursive_combat({Enum.slice(deck1, 0, card1), Enum.slice(deck2, 0, card2)})
        |> case do
          {:player1, _} ->
            play_recursive_combat({deck1 ++ [card1, card2], deck2}, MapSet.put(mem, decks))

          {:player2, _} ->
            play_recursive_combat({deck1, deck2 ++ [card2, card1]}, MapSet.put(mem, decks))
        end
      else
        cond do
          card1 > card2 ->
            play_recursive_combat({deck1 ++ [card1, card2], deck2}, MapSet.put(mem, decks))

          card1 < card2 ->
            play_recursive_combat({deck1, deck2 ++ [card2, card1]}, MapSet.put(mem, decks))
        end
      end
    end
  end

  def resolve_first_part, do: parse_input() |> play_combat |> (&score(elem(&1, 1))).()
  def resolve_second_part, do: parse_input() |> play_recursive_combat |> (&score(elem(&1, 1))).()
end

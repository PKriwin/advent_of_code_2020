defmodule AdventOfCode.Puzzle9 do
  use AdventOfCode.Puzzle, no: 9

  def parse_input, do: get_input() |> Enum.map(&String.to_integer/1)

  def in_preamble(nb, preamble, nb_of_terms) do
    Comb.combinations(preamble, nb_of_terms)
    |> Enum.reduce(%MapSet{}, &MapSet.put(&2, Enum.sum(&1)))
    |> MapSet.member?(nb)
  end

  def first_nb_not_in_preamble(all_numbers, preamble_size \\ 25, nb_of_terms \\ 2) do
    all_numbers
    |> Enum.drop(preamble_size)
    |> Enum.with_index()
    |> Enum.find_value(fn {nb, index} ->
      if !in_preamble(nb, Enum.slice(all_numbers, index..(index + preamble_size)), nb_of_terms),
        do: nb
    end)
  end

  def encryption_weakness(all_numbers, preamble_size \\ 25, nb_of_terms \\ 2) do
    key_number = first_nb_not_in_preamble(all_numbers, preamble_size, nb_of_terms)

    0..length(all_numbers)
    |> Enum.reduce_while(nil, fn lower_bound, _ ->
      Enum.reduce_while((lower_bound + 1)..length(all_numbers), nil, fn upper_bound, _ ->
        subarray = Enum.slice(all_numbers, lower_bound..upper_bound)
        subarray_value = Enum.sum(subarray)

        if subarray_value >= key_number,
          do: {:halt, {subarray, subarray_value}},
          else: {:cont, nil}
      end)
      |> case do
        {subarray, ^key_number} -> {:halt, subarray}
        _ -> {:cont, nil}
      end
    end)
    |> (&(Enum.min(&1) + Enum.max(&1))).()
  end

  def resolve_first_part, do: parse_input() |> first_nb_not_in_preamble()
  def resolve_second_part, do: parse_input() |> encryption_weakness()
end

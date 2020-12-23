defmodule AdventOfCode.Puzzle8 do
  use AdventOfCode.Puzzle, no: 8

  def parse_input() do
    get_input()
    |> Enum.map(fn instruction ->
      [opcode, param] = Regex.run(~r/^(\w{3}) ([+-]\d+)$/, instruction, capture: :all_but_first)
      {String.to_atom(opcode), String.to_integer(param)}
    end)
  end

  defmodule Emulator do
    defstruct ip: 0, pgm: [], acc: 0
  end

  def validate_state(%Emulator{ip: ip}, state_history) do
    cond do
      Enum.find(state_history, &(&1.ip == ip)) != nil -> {:error, :duplicate_ip}
      true -> :ok
    end
  end

  def run(%Emulator{ip: ip, pgm: pgm, acc: acc} = state, state_history \\ []) do
    case validate_state(state, state_history) do
      {:error, reason} ->
        {:crash, reason, %{ip: ip, acc: acc, state_history: state_history}}

      :ok ->
        case Enum.at(pgm, ip) do
          nil ->
            acc

          {op_code, param} ->
            case op_code do
              :acc -> %{ip: ip + 1, acc: acc + param}
              :jmp -> %{ip: ip + param}
              :nop -> %{ip: ip + 1}
            end
            |> (&run(Map.merge(state, &1), [Map.take(state, [:ip, :acc]) | state_history])).()
        end
    end
  end

  def boot(pgm), do: run(%Emulator{pgm: pgm})

  def fix_and_boot(pgm) do
    pgm
    |> Enum.with_index()
    |> Enum.filter(fn {{opcode, _}, _} -> opcode == :nop or opcode == :jmp end)
    |> Enum.reduce_while(nil, fn {{opcode, param}, index}, _ ->
      pgm
      |> List.replace_at(index, {(opcode == :jmp && :nop) || :jmp, param})
      |> boot()
      |> case do
        {:crash, _, _} -> {:cont, nil}
        acc -> {:halt, acc}
      end
    end)
  end

  def resolve_first_part(),
    do: parse_input() |> boot() |> (fn {:crash, _, %{acc: acc}} -> acc end).()

  def resolve_second_part(), do: parse_input() |> fix_and_boot()
end

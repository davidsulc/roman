defmodule Roman.Validators.Numeral do
  @moduledoc false

  @valid_numerals ~w(M D C L X V I)

  @type ok_numeral_or_error :: {:ok, Roman.numeral} | Roman.error

  @spec validate(Roman.numeral) :: Roman.numeral | Roman.error
  def validate(numeral, opts \\ [strict: true]) when is_binary(numeral) do
    with  {:ok, numeral} <- only_valid_numerals(numeral),
          {:strict, true, numeral} <- {:strict, opts[:strict], numeral},
          {:ok, numeral} <- only_one_v_l_d(numeral),
          {:ok, numeral} <- max_3_consecutive_repetitions(numeral) do
      {:ok, numeral}
    else
      {:strict, _, numeral} -> {:ok, numeral}
      {:error, _} = error -> error
    end
  end

  @spec only_valid_numerals(Roman.numeral) :: ok_numeral_or_error
  defp only_valid_numerals(numeral) do
    numeral
    |> to_letters
    |> Enum.reject(&Enum.member?(@valid_numerals, &1))
    |> case do
      [] -> {:ok, numeral}
      invalid_letters ->
        pretty_numerals = Enum.join(@valid_numerals, ", ")
        {:error, {:invalid_letter, "numeral contains invalid letter(s), "
            <> "valid letters are #{pretty_numerals} but encountered "
            <> Enum.join(invalid_letters, ", ")}}
    end
  end

  @spec to_letters(Roman.numeral) :: [Roman.numeral]
  defp to_letters(numeral), do: String.split(numeral, "", trim: true)

  @spec only_one_v_l_d(Roman.numeral) :: ok_numeral_or_error
  defp only_one_v_l_d(numeral) do
    numeral
    |> to_letters
    |> Enum.reduce(%{}, &update_letter_count/2)
    |> Stream.filter(fn {_, v} -> v > 1 end)
    |> Stream.map(fn {k, _} -> k end)
    |> Enum.to_list
    |> case do
      [] -> {:ok, numeral}
      keys ->
        {:error, {:repeated_vld,
            "letters V, L, and D can appear only once, "
            <> "but found several instances of #{Enum.join(keys, ", ")}"}}
    end
  end

  @spec update_letter_count(String.t, map) :: {:cont, map} | {:halt, map}
  defp update_letter_count(letter, count_map) when letter in ~w(V L D) do
    count = Map.get(count_map,  letter, 0) + 1
    if count <= 3 do
      Map.put(count_map, letter, count)
    else
      count_map
    end
  end

  defp update_letter_count(_, acc), do: acc

  @spec max_3_consecutive_repetitions(Roman.numeral) :: ok_numeral_or_error
  defp max_3_consecutive_repetitions(numeral) do
    numeral
    |> to_letters
    |> Stream.unfold(fn
      [h | _] = letters ->
        {same, rest} = Enum.split_while(letters, & &1 == h)
        {{h, Enum.count(same)}, rest}
      [] -> nil
    end)
    |> Stream.filter(fn {_, count} -> count > 3 end)
    |> Stream.map(fn {l, _} -> l end)
    |> Enum.to_list
    |> case do
      [] -> {:ok, numeral}
      letters ->
        {:error, {:identical_letter_seq_too_long,
            "a given letter cannot appear more than 3 times in a row: "
            <> "encountered invalid sequences for #{Enum.join(letters, ", ")}"}}
    end
  end
end

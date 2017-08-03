defmodule Roman.Validators.Numeral do
  @moduledoc false

  @type numeral_or_error :: Roman.numeral | Roman.error

  @doc """
  Validates the numeral.

  Runs all other validators defined in this module, returning the given
  numeral or `{:error, atom, message}` on validation failure.
  """
  @spec validate(Roman.numeral) :: Roman.numeral | Roman.error
  def validate(numeral) when is_binary(numeral) do
    numeral
    |> only_valid_numerals
    |> max_3_consecutive_repetitions
    |> only_one_v_l_d
  end

  @doc """
  Validates the numeral contains only valid letters.

  Returns the given roman numeral, or `{:error, :invalid_letter, message}` on
  validation failure.

  ### Example

  iex> only_valid_numerals("MDCLXVI")
  "MDCLXVI"
  iex> only_valid_numerals("SIXT")
  {:error, :invalid_letter,
  "numeral contains invalid letter(s), valid letters are M, D, C, L, X, V, I "
  <> "but encountered S, T"}
  """
  @spec only_valid_numerals(numeral_or_error) :: numeral_or_error
  def only_valid_numerals({:error, _, _} = error), do: error
  def only_valid_numerals(numeral) do
    numeral
    |> to_letters
    |> Enum.reject(&Enum.member?(valid_numerals(), &1))
    |> case do
      [] -> numeral
      invalid_letters ->
        pretty_numerals = Enum.join(valid_numerals(), ", ")
        {:error, :invalid_letter, "numeral contains invalid letter(s), "
            <> "valid letters are #{pretty_numerals} but encountered "
            <> Enum.join(invalid_letters, ", ")}
    end
  end

  @spec to_letters(Roman.numeral) :: [Roman.numeral]
  defp to_letters(numeral), do: String.split(numeral, "", trim: true)

  def valid_numerals, do: ~w(M D C L X V I)

  @doc """
  Validates that numbers beginning with a '5' (V, L and D) only appear once.

  Returns the given roman numeral, or `{:error, :repeated_vld, message}` on
  validation failure.

  ### Example

  iex> only_one_v_l_d("XVI")
  "XVI"
  iex> only_one_v_l_d("LLVIV")
  {:error, :repeated_vld, "letters V, L, and D can appear only once, but found "
  <> "several instances of L, V"}
  """
  @spec only_one_v_l_d(numeral_or_error) :: numeral_or_error
  def only_one_v_l_d({:error, _, _} = error), do: error
  def only_one_v_l_d(numeral) when is_binary(numeral) do
    numeral
    |> to_letters
    |> Enum.reduce(%{}, &update_letter_count/2)
    |> Stream.filter(fn {_, v} -> v > 1 end)
    |> Stream.map(fn {k, _} -> k end)
    |> Enum.to_list
    |> case do
      [] -> numeral
      keys ->
        {:error, :repeated_vld,
            "letters V, L, and D can appear only once, "
            <> "but found several instances of #{Enum.join(keys, ", ")}"}
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

  @doc """
  Validates that letters within the numeral repeat at most 3 times.

  Returns the given roman numeral, or
  `{:error, :identical_letter_seq_too_long, message}` on validation failure.

  ### Example

  iex> max_3_consecutive_repetitions("XIII")
  "XIII"
  iex> max_3_consecutive_repetitions("CCCCXIIII")
  {:error, :identical_letter_seq_too_long,
      "a given letter cannot appear more than 3 times in a row: "
      <> "encountered invalid sequences for C, I"}
  """
  @spec max_3_consecutive_repetitions(numeral_or_error) :: numeral_or_error
  def max_3_consecutive_repetitions({:error, _, _} = error), do: error
  def max_3_consecutive_repetitions(numeral) do
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
      [] -> numeral
      letters ->
        {:error, :identical_letter_seq_too_long,
            "a given letter cannot appear more than 3 times in a row: "
            <> "encountered invalid sequences for #{Enum.join(letters, ", ")}"}
    end
  end
end

defmodule Roman do
  @moduledoc """
  Functions to work with roman numerals from 1 to 4000 (not included)
  """

  @external_resource "lib/numerals.txt"

  @numeral_pairs (
    @external_resource
    |> File.stream!
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [val, num] -> {String.to_integer(val), num} end)
    |> Enum.to_list
  )

  @type error :: {atom, atom, String.t}
  @type numeral :: String.t

  @doc """
  Returns a list of `{int_value, numeral_string}` tuples for all possible
  numerals.
  """
  @spec numeral_pairs() :: [{number, numeral}]
  def numeral_pairs, do: @numeral_pairs

  @doc """
  Decodes a roman numeral string into the corresponding integer value.

  This function returns:

  - `{:ok, value}` - the integer value of the provided numeral.
  - `{:error, reason, message}` - the provided numeral is invalid.

  Possible errors are:

  - `{:error, :empty_string, _}`: string is empty
  - `{:error, :invalid_letter, _}`: if the provided string contains a character
      that isn't one of I, V, X, L, C, D, M
  - `{:error, :repeated_vld, _}`: string contains more than one instance each
      of letters V, L, and D (i.e. numerals corresponding to numbers starting
      with a 5)
  - `{:error, :identical_letter_seq_too_long, _}`: string has a sequence of 4
      or more identical letters
  - `{:error, :sequence_increasing, _}`: string contains a value greater than
      one appearing before it (rule applies to combined value in subtractive
      case)
  - `{:error, :value_greater_than_subtraction, _}`: string contains a value
      matching or exceding a previously subtracted value

  ### Examples

      iex> Roman.decode("MMMDCCCXCVIII")
      {:ok, 3898}
      iex> Roman.decode("LLVIV")
      {:error, :repeated_vld,
      "letters V, L, and D can appear only once, but found several instances of L, V"}
  """
  @spec decode(String.t) :: {:ok, number} | Roman.error
  defdelegate decode(numeral), to: __MODULE__.Decoder

  @doc """
  Returns a boolean indicating whether the provided string is a valid numeral.

  iex> Roman.numeral?("VI")
  true
  iex> Roman.numeral?("FOO")
  false
  """
  @spec numeral?(String.t) :: boolean
  def numeral?(string) do
    case decode(string) do
      {:ok, _} -> true
      _ -> false
    end
  end
end

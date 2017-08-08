defmodule Roman do
  @moduledoc """
  Functions to work with roman numerals in the 1..3999 range
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

  @doc false
  @spec numeral_pairs() :: [{integer, numeral}]
  def numeral_pairs, do: @numeral_pairs

  @doc """
  Decodes a roman numeral string into the corresponding integer value.

  Strings with non-uppercase letters will only be decoded if the `:ignore_case`
  option is set to `true`.

  ## Options
    * `:ignore_case` (boolean) - if `true`, strings will be decoded regardless
      of casing. If `false` (default), strings containing a lowercase letter
      will return an error.

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
      iex> Roman.decode("vi", ignore_case: true)
      {:ok, 6}
      iex> Roman.decode("LLVIV")
      {:error, :repeated_vld,
      "letters V, L, and D can appear only once, but found several instances of L, V"}
  """
  @spec decode(String.t, keyword) :: {:ok, integer} | Roman.error
  defdelegate decode(numeral, options \\ []), to: __MODULE__.Decoder

  @doc """
  Similar to `decode/1` but raises an error if the numeral could not be
  decoded.

  If it succeeds in decoding the numeral, it returns corresponding value.
  """
  @spec decode!(String.t, keyword) :: integer | no_return
  def decode!(numeral, options \\ []) do
    case decode(numeral, options) do
      {:ok, val} ->
        val
      {:error, _, message} ->
        raise ArgumentError, message: message
    end
  end

  @doc """
  Encodes an integer into a roman numeral.

  Only values in the 1..3999 range can be encoded.

  This function returns:

  - `{:ok, numeral}` - the nuermal corresponding to the provided integer.
  - `{:error, :invalid_integer, message}` - the provided integer is not within
      the acceptable 1..3999 range.

  ### Examples

      iex> Roman.encode(3898)
      {:ok, "MMMDCCCXCVIII"}
      iex> Roman.encode(4000)
      {:error, :invalid_integer, "cannot encode values outside of range 1..3999"}
  """
  @spec encode(integer) :: {:ok, Roman.numeral} | Roman.error
  defdelegate encode(integer), to: __MODULE__.Encoder

  @doc """
  Similar to `encode/1` but raises an error if the integer could not be
  encoded.

  If it succeeds in encoding the numeral, it returns corresponding numeral.
  """
  @spec encode!(integer) :: Roman.numeral | no_return
  def encode!(int) do
    case encode(int) do
      {:ok, numeral} ->
        numeral
      {:error, _, message} ->
        raise ArgumentError, message: message
    end
  end

  @doc """
  Returns a boolean indicating whether the provided string is a valid numeral.

  ## Options
    * `:ignore_case` (boolean) - if `true`, strings will be evaluated while
      ignoring casing. If `false` (default), strings containing a lowercase
      letter will return `false`.

  iex> Roman.numeral?("VI")
  true
  iex> Roman.numeral?("FOO")
  false
  iex> Roman.numeral?("x")
  false
  iex> Roman.numeral?("x", ignore_case: true)
  true
  """
  @spec numeral?(String.t, keyword) :: boolean
  def numeral?(string, options \\ []) do
    case decode(string, options) do
      {:ok, _} -> true
      _ -> false
    end
  end
end

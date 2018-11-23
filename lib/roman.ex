defmodule Roman do
  @moduledoc """
  Functions to work with roman numerals in the `1..3999` range
  """

  @external_resource "lib/numerals.txt"

  @numeral_pairs @external_resource
                 |> File.stream!()
                 |> Stream.map(&String.split/1)
                 |> Stream.map(fn [val, num] -> {String.to_integer(val), num} end)
                 |> Enum.to_list()

  @type error :: {:error, error_tuple}
  @type error_tuple :: {atom, String.t()}
  @type numeral :: String.t()

  @doc false
  @spec numeral_pairs() :: [{integer, numeral}]
  def numeral_pairs, do: @numeral_pairs

  @doc """
  Decodes a roman numeral string into the corresponding integer value.

  Strings with non-uppercase letters will only be decoded if the `:ignore_case`
  option is set to `true`.

  ## Options
    * `:explain` (boolean) - if `true`, error reasons will be more specific in
      indicating what the problem with the provided numeral is (slightly
      degrades performance in error cases, as the numeral must be inspected to
      determine the cause of the error). If `false` (default), a generic error
      reason will be returned in most cases (see "Error reasons" below for more
      information).
    * `:ignore_case` (boolean) - if `true`, strings will be decoded regardless
      of casing. If `false` (default), strings containing a lowercase letter
      will return an error.
    * `:strict` (boolean) - if `true` (default), strings not conforming to
      [composition rules](composition_rules.html) will return an error. If `false` the numeral components
      will be decomposed and added, and the result will be returned.
    * `:zero` - if `true`, the numeral N will be decoded as 0. This option has
      no influence on decoding other numerals.

    Default values for options can be set in `config.exs`using the `:roman`
    application and the `:default_flags` key, for example:

        `config :roman, :default_flags, %{ignore_case: true}`

    The values will remain overrideable on a per-call basis by passing the
    desired option value.

  This function returns:

  - `{:ok, value}` - the integer value of the provided numeral.
  - `{:error, reason}` - the provided numeral is invalid.

  ## Error reasons

  Possible error reasons are listed below.

  When `:explain` is `false` (default value):

  - `{:empty_string, _}`: string is empty.
  - `{:invalid_numeral, _}`: string isn't a valid numeral.

  When `:explain` is `true`:

  - `{:empty_string, _}`: string is empty.
  - `{:invalid_letter, _}`: if the provided string contains a
      character that isn't one of I, V, X, L, C, D, M.
  - `{:repeated_vld, _}`: string contains more than one instance each
      of letters V, L, and D (i.e. numerals corresponding to numbers starting
      with a 5). Cannot happen if `:strict` is `false`.
  - `{:identical_letter_seq_too_long, _}`: string has a sequence of 4
      or more identical letters. Cannot happen if `:strict` is `false`.
  - `{:sequence_increasing, _}`: string contains a value greater than
      one appearing before it (rule applies to combined value in subtractive
      case). Cannot happen if `:strict` is `false`.
  - `{:value_greater_than_subtraction, _}`: string contains a value
      matching or exceding a previously subtracted value. Cannot happen if
      `:strict` is `false`.

  For more information on how roman numerals should be composed according to
  the `:strict` rules, see the [composition rules](composition_rules.html)
  documentation page.

  ### Examples

      iex> Roman.decode("MMMDCCCXCVIII")
      {:ok, 3898}
      iex> Roman.decode("vi", ignore_case: true)
      {:ok, 6}
      iex> Roman.decode("N", zero: true)
      {:ok, 0}
      iex> Roman.decode("IIII", strict: false)
      {:ok, 4}
      iex> Roman.decode("LLVIV")
      {:error, {:invalid_numeral, "numeral is invalid"}}
      iex> Roman.decode("LLVIV", explain: true)
      {:error, {:repeated_vld,
      "letters V, L, and D can appear only once, but found several instances of L, V"}}
  """
  @spec decode(String.t(), keyword) :: {:ok, integer} | Roman.error()
  defdelegate decode(numeral, options \\ []), to: __MODULE__.Decoder

  @doc """
  Similar to `decode/1` but raises an error if the numeral could not be
  decoded.

  If it succeeds in decoding the numeral, it returns corresponding value.
  """
  @spec decode!(String.t(), keyword) :: integer | no_return
  def decode!(numeral, options \\ []) do
    case decode(numeral, options) do
      {:ok, val} ->
        val

      {:error, {_, message}} ->
        raise ArgumentError, message: message
    end
  end

  @doc """
  Encodes an integer into a roman numeral.

  Only values in the `1..3999` range can be encoded.

  This function returns:

  - `{:ok, numeral}` - the nuermal corresponding to the provided integer.
  - `{:error, {:invalid_integer, message}}` - the provided integer is not within
      the acceptable `1..3999` range.

  ### Examples

      iex> Roman.encode(3898)
      {:ok, "MMMDCCCXCVIII"}
      iex> Roman.encode(4000)
      {:error, {:invalid_integer,
      "cannot encode values outside of range 1..3999"}}
  """
  @spec encode(integer) :: {:ok, Roman.numeral()} | Roman.error()
  defdelegate encode(integer), to: __MODULE__.Encoder

  @doc """
  Similar to `encode/1` but raises an error if the integer could not be
  encoded.

  If it succeeds in encoding the numeral, it returns the corresponding numeral.
  """
  @spec encode!(integer) :: Roman.numeral() | no_return
  def encode!(int) do
    case encode(int) do
      {:ok, numeral} ->
        numeral

      {:error, {_, message}} ->
        raise ArgumentError, message: message
    end
  end

  @doc """
  Returns a boolean indicating whether the provided string is a valid numeral.

  The return value indicates whether a call to `decode/2` would be successful.

  Accepts the same options and returns the same error values as `decode/2`.

  ```
  iex> Roman.numeral?("VI")
  true
  iex> Roman.numeral?("FOO")
  false
  iex> Roman.numeral?("x")
  false
  iex> Roman.numeral?("x", ignore_case: true)
  true
  iex> Roman.numeral?("VXL", strict: false)
  true
  ```
  """
  @spec numeral?(String.t(), keyword) :: boolean
  def numeral?(string, options \\ []) do
    case decode(string, options) do
      {:ok, _} -> true
      _ -> false
    end
  end
end

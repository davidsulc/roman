defmodule Roman.Decoder do
  @moduledoc false

  alias Roman.Validators.{Numeral, Sequence}

  @type decoded_numeral :: {Roman.numeral, map}
  @type decoded_numeral_sequence :: [decoded_numeral]

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

      iex> decode("MMMDCCCXCVIII")
      {:ok, 3898}
      iex> decode("vi", ignore_case: true)
      {:ok, 6}
      iex> decode("LLVIV")
      {:error, :repeated_vld,
      "letters V, L, and D can appear only once, but found several instances of L, V"}
  """
  @spec decode(String.t, keyword) :: number | Roman.error
  def decode(numeral, options) do
    maybe_upcase = fn numeral ->
      if options[:ignore_case] == true do
        String.upcase(numeral)
      else
        numeral
      end
    end

    numeral
    |> maybe_upcase.()
    |> decode
  end

  @spec decode(String.t) :: number | Roman.error
  def decode(""),
    do: {:error, :empty_string, "expected a numeral, got an empty string"}

  for {val, num} <- Roman.numeral_pairs do
    def decode(unquote(num)), do: {:ok, unquote(val)}
  end

  # The below code is fully capable of decoding numeral values on its own:
  # the above function head matches were added for better performance.
  # The below implementation will return a detailed error message indicating
  # why a numeral couldn't be parsed.
  def decode(numeral) when is_binary(numeral) do
    with  {:ok, numeral} <- Numeral.validate(numeral),
          {:ok, seq} <- decode_sections(numeral),
          {:ok, seq} <- Sequence.validate(seq) do
      Enum.reduce(seq, 0, fn {_, %{value: v}}, acc -> v + acc end)
    else
      {:error, _, _} = error -> error
    end
  end

  @spec decode_sections(Roman.numeral) :: decoded_numeral_sequence | Roman.error
  defp decode_sections(numeral) do
    sequence =
      numeral
      |> Stream.unfold(&decode_section/1)
      |> Enum.to_list

    {:ok, sequence}
  end

  # When decoding, we need to keep track of whether we've already encountered a
  # subtractive combination, and how much the subtraction was: this will be
  # necessary for further validation later
  @spec decode_section(Roman.numeral) :: {decoded_numeral, Roman.numeral} | nil
  defp decode_section("CM" <> rest),
    do: {{"CM", %{value: 900, delta: 100}}, rest}

  defp decode_section("CD" <> rest),
    do: {{"CD", %{value: 400, delta: 100}}, rest}

  defp decode_section("XC" <> rest),
    do: {{"XC", %{value: 90, delta: 10}}, rest}

  defp decode_section("XL" <> rest),
    do: {{"XL", %{value: 40, delta: 10}}, rest}

  defp decode_section("IX" <> rest),
    do: {{"IX", %{value: 9, delta: 1}}, rest}

  defp decode_section("IV" <> rest),
    do: {{"IV", %{value: 4, delta: 1}}, rest}

  defp decode_section("M" <> rest),
    do: {{"M", %{value: 1_000}}, rest}

  defp decode_section("D" <> rest),
    do: {{"D", %{value: 500}}, rest}

  defp decode_section("C" <> rest),
    do: {{"C", %{value: 100}}, rest}

  defp decode_section("L" <> rest),
    do: {{"L", %{value: 50}}, rest}

  defp decode_section("X" <> rest),
    do: {{"X", %{value: 10}}, rest}

  defp decode_section("V" <> rest),
    do: {{"V", %{value: 5}}, rest}

  defp decode_section("I" <> rest),
    do: {{"I", %{value: 1}}, rest}

  defp decode_section(""), do: nil
end

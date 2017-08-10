defmodule Roman.Decoder do
  @moduledoc false

  alias Roman.Validators.{Numeral, Sequence}

  @default_error {:error, {:invalid_numeral, "numeral is invalid"}}
  @valid_options [:explain, :ignore_case, :strict]

  @type decoded_numeral :: {Roman.numeral, map}

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
  - `{:error, reason}` - the provided numeral is invalid.

  Possible errors are:

  - `{:empty_string, _}`: string is empty
  - `{:invalid_letter, _}`: if the provided string contains a character
      that isn't one of I, V, X, L, C, D, M
  - `{:repeated_vld, _}`: string contains more than one instance each
      of letters V, L, and D (i.e. numerals corresponding to numbers starting
      with a 5)
  - `{:identical_letter_seq_too_long, _}`: string has a sequence of 4
      or more identical letters
  - `{:sequence_increasing, _}`: string contains a value greater than
      one appearing before it (rule applies to combined value in subtractive
      case)
  - `{:value_greater_than_subtraction, _}`: string contains a value
      matching or exceding a previously subtracted value

  ### Examples

      iex> decode("MMMDCCCXCVIII")
      {:ok, 3898}
      iex> decode("vi", ignore_case: true)
      {:ok, 6}
      iex> decode("LLVIV")
      {:error, {:invalid_numeral, "numeral is invalid"}}
      iex> decode("LLVIV", explain: true)
      {:error, {:repeated_vld,
      "letters V, L, and D can appear only once, but found several instances of L, V"}}
  """
  @spec decode(String.t, keyword | map) :: {:ok, integer} | Roman.error
  def decode(numeral, options \\ [])

  def decode(numeral, options) when is_binary(numeral) and is_list(options) do
    flags =
      options
      |> Keyword.take(@valid_options)
      |> Enum.into(%{explain: false, ignore_case: false, strict: true})

    maybe_upcase = fn
      numeral, %{ignore_case: true} -> String.upcase(numeral)
      numeral, _                    -> numeral
    end

    numeral
    |> maybe_upcase.(flags)
    |> decode(flags)
  end

  def decode("", _),
    do: {:error, {:empty_string, "expected a numeral, got an empty string"}}

  for {val, num} <- Roman.numeral_pairs do
    def decode(unquote(num), _), do: {:ok, unquote(val)}
  end

  def decode(numeral, %{strict: true, explain: false}) when is_binary(numeral) do
    @default_error
  end

  # complete numeral decoder to handle "alternative forms"
  # see e.g. https://en.wikipedia.org/wiki/Roman_numerals#Alternative_forms
  def decode(numeral, %{explain: explain} = opts) when is_binary(numeral) do
    case get_sequence(numeral, opts) do
      {:error, _} = error ->
        if explain, do: error, else: @default_error
      {:ok, seq} ->
        {:ok, Enum.reduce(seq, 0, fn {_, %{value: v}}, acc -> v + acc end)}
    end
  end

  @spec get_sequence(Roman.numeral, map)
      :: {:ok, [decoded_numeral]} | Roman.error
  defp get_sequence(numeral, %{strict: strict}) do
    with  {:ok, numeral} <- Numeral.validate(numeral, strict: strict),
          {:ok, seq} <- decode_sections(numeral) do
      if strict, do: Sequence.validate(seq), else: {:ok, seq}
    else
      {:error, _} = error -> error
    end
  end

  @spec decode_sections(Roman.numeral) :: {:ok, [decoded_numeral]} | Roman.error
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

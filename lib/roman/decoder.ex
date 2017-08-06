defmodule Roman.Decoder do
  @moduledoc false

  @type decoded_numeral :: {Roman.numeral, map}
  @type decoded_numeral_sequence :: [decoded_numeral]

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
    numeral
    |> Roman.Validators.Numeral.validate
    |> decode_sections
    |> validate_section_sequence
    |> compute_result
    |> case do
      {:error, _, _} = error -> error
      value -> {:ok, value}
    end
  end

  @spec decode_sections(Roman.numeral | Roman.error)
      :: decoded_numeral_sequence | Roman.error
  defp decode_sections({:error, _, _} = error), do: error
  defp decode_sections(numeral) do
    numeral
    |> Stream.unfold(&decode_section/1)
    |> Enum.to_list
  end

  @spec validate_section_sequence(decoded_numeral_sequence | Roman.error)
      :: number | Roman.error
  defp validate_section_sequence({:error, _, _} = error), do: error
  defp validate_section_sequence(seq),
    do: Roman.Validators.Sequence.validate(seq)

  @spec compute_result(decoded_numeral_sequence | Roman.error)
      :: number | Roman.error
  defp compute_result({:error, _, _} = error), do: error
  defp compute_result(seq),
    do: Enum.reduce(seq, 0, fn {_, %{value: v}}, acc -> v + acc end)

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

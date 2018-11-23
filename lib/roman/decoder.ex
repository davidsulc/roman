defmodule Roman.Decoder do
  @moduledoc false

  alias Roman.Validators.{Numeral, Sequence}

  @default_error {:error, {:invalid_numeral, "numeral is invalid"}}
  @valid_options [:explain, :ignore_case, :strict, :zero]

  @type decoded_numeral :: {Roman.numeral(), map}

  @spec decode(String.t(), keyword | map) :: {:ok, integer} | Roman.error()
  def decode(numeral, options \\ [])

  def decode(numeral, options) when is_binary(numeral) and is_list(options) do
    flags =
      options
      |> Keyword.take(@valid_options)
      |> Enum.into(default_flags())

    maybe_upcase = fn
      numeral, %{ignore_case: true} -> String.upcase(numeral)
      numeral, _ -> numeral
    end

    numeral
    |> maybe_upcase.(flags)
    |> decode(flags)
  end

  def decode("", _),
    do: {:error, {:empty_string, "expected a numeral, got an empty string"}}

  def decode("N", %{zero: true}),
    do: {:ok, 0}

  for {val, num} <- Roman.numeral_pairs() do
    def decode(unquote(num), _), do: {:ok, unquote(val)}
  end

  def decode(numeral, %{strict: true, explain: false}) when is_binary(numeral) do
    @default_error
  end

  # complete numeral decoder to handle "alternative forms"
  # see e.g. https://en.wikipedia.org/wiki/Roman_numerals#Alternative_forms
  def decode(numeral, %{explain: explain} = opts) when is_binary(numeral) do
    case sequence(numeral, opts) do
      {:error, _} = error ->
        if explain, do: error, else: @default_error

      {:ok, seq} ->
        {:ok, Enum.reduce(seq, 0, fn {_, %{value: v}}, acc -> v + acc end)}
    end
  end

  @spec default_flags() :: map
  defp default_flags do
    config =
      :roman
      |> Application.get_env(:default_flags, %{})
      |> Map.take(@valid_options)

    %{
      explain: false,
      ignore_case: false,
      strict: true
    }
    |> Map.merge(config)
  end

  @spec sequence(Roman.numeral(), map) :: {:ok, [decoded_numeral]} | Roman.error()
  defp sequence(numeral, %{strict: strict}) do
    with {:ok, numeral} <- Numeral.validate(numeral, strict: strict),
         {:ok, seq} <- decode_sections(numeral) do
      if strict, do: Sequence.validate(seq), else: {:ok, seq}
    else
      {:error, _} = error -> error
    end
  end

  @spec decode_sections(Roman.numeral()) :: {:ok, [decoded_numeral]} | Roman.error()
  defp decode_sections(numeral) do
    sequence =
      numeral
      |> Stream.unfold(&decode_section/1)
      |> Enum.to_list()

    {:ok, sequence}
  end

  # When decoding, we need to keep track of whether we've already encountered a
  # subtractive combination, and how much the subtraction was: this will be
  # necessary for further validation later
  @spec decode_section(Roman.numeral()) :: {decoded_numeral, Roman.numeral()} | nil
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

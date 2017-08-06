defmodule Roman do
  @moduledoc """
  Functions to work with roman numerals
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

  @spec numeral_pairs() :: [{number, numeral}]
  def numeral_pairs, do: @numeral_pairs

  defdelegate decode(numeral), to: __MODULE__.Decoder
end

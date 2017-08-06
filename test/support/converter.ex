defmodule Test.Support.Converter do
  @moduledoc false

  numerals = Enum.map(Roman.numeral_pairs, fn {_, n} -> n end)
  @spec all_numerals() :: [Roman.numeral]
  def all_numerals, do: unquote(numerals)

  @spec convert(Roman.numeral | number) :: Roman.numeral | number
  for {val, num} <- Roman.numeral_pairs do
    def convert(unquote(num)), do: unquote(val)
    def convert(unquote(val)), do: unquote(num)
  end
end

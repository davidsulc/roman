defmodule Roman.Encoder do
  @moduledoc false

  @spec encode(integer) :: Roman.numeral() | Roman.error()
  for {val, num} <- Roman.numeral_pairs() do
    def encode(unquote(val)), do: {:ok, unquote(num)}
  end

  def encode(int) when is_integer(int) do
    {:error, {:invalid_integer, "cannot encode values outside of range 1..3999"}}
  end
end

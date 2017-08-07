defmodule Roman.Validators.NumeralTest do
  use ExUnit.Case, async: true

  alias Roman.Validators.Numeral

  doctest Numeral, import: true

  test "validate/1" do
    assert Numeral.validate("XVI") == {:ok, "XVI"}
    assert {:error, :invalid_letter, _} = Numeral.validate("SIXT")
    assert {:error, :repeated_vld, _} = Numeral.validate("LLVIV")
    assert {:error, :identical_letter_seq_too_long, _} =
        Numeral.validate("CCCCXIIII")
  end
end

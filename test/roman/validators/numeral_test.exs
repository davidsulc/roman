defmodule Roman.Validators.NumeralTest do
  use ExUnit.Case, async: true

  alias Roman.Validators.Numeral

  doctest Numeral, import: true

  describe "only_valid_numerals/1" do
    test "errors pass through" do
      error = {:error, :foo, "bar"}
      assert Numeral.only_valid_numerals(error) == error
    end
  end

  describe "only_one_v_l_d/1" do
    test "errors pass through" do
      error = {:error, :foo, "bar"}
      assert Numeral.only_one_v_l_d(error) == error
    end
  end

  describe "max_3_consecutive_repetitions/1" do
    test "errors pass through" do
      error = {:error, :foo, "bar"}
      assert Numeral.max_3_consecutive_repetitions(error) == error
    end
  end
end

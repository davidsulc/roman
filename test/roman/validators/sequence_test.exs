defmodule Roman.Validators.SequenceTest do
  use ExUnit.Case, async: true

  alias Roman.Validators.Sequence

  doctest Sequence, import: true

  describe "increasing_value_order/1" do
    test "errors pass through" do
      error = {:error, :foo, "bar"}
      assert Sequence.increasing_value_order(error) == error
    end
  end

  describe "subtraction_bounds_following_values/1" do
    test "errors pass through" do
      error = {:error, :foo, "bar"}
      assert Sequence.subtraction_bounds_following_values(error) == error
    end
  end
end

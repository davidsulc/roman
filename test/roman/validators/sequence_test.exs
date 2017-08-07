defmodule Roman.Validators.SequenceTest do
  use ExUnit.Case, async: true

  alias Roman.Validators.Sequence

  doctest Sequence, import: true

  test "validate/1" do
    seq = [{"V", %{value: 5}}, {"X", %{value: 10}}]
    assert {:error, :sequence_increasing, _} = Sequence.validate(seq)

    seq = [{"CM", %{value: 900, delta: 100}}, {"C", %{value: 100}}]
    assert {:error, :value_greater_than_subtraction, _} = Sequence.validate(seq)
  end
end

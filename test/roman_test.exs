defmodule RomanTest do
  use ExUnit.Case, async: true
  doctest Roman

  alias Test.Support.Converter

  describe "decode/1 validations" do
    test "empty string is invalid" do
      assert {:error, :empty_string, _} = Roman.decode("")
    end

    test "IT is invalid" do
      assert {:error, :invalid_letter, _} = Roman.decode("IT")
    end

    test "VIV is invalid" do
      assert {:error, :repeated_vld, _} = Roman.decode("VIV")
    end

    test "IIII is invalid" do
      assert {:error, :identical_letter_seq_too_long, _} =
          Roman.decode("IIII")
    end

    test "VX is invalid" do
      assert {:error, :sequence_increasing, _} = Roman.decode("VX")
    end

    test "CMC is invalid" do
      assert {:error, :value_greater_than_subtraction, _} =
          Roman.decode("CMC")
    end
  end

  describe "decode/1" do
    test "all valid numerals" do
      for num <- Converter.all_numerals do
        expected = Converter.convert(num)
        {:ok, result} = Roman.decode(num)
        assert result == expected,
            "Expected decode(\"#{num}\") to yield #{expected}, but got #{result}"
      end
    end

    test ":ignore_case option" do
      assert {:error, _, _} = Roman.decode("x")
      assert Roman.decode("x", ignore_case: true) == {:ok, 10}
    end

    test ":strict option" do
      assert {:error, _, _} = Roman.decode("IIII")
      assert {:error, _, _} = Roman.decode("A", strict: false)
      # example of alternative numerals taken from
      # https://en.wikipedia.org/wiki/Roman_numerals#Alternative_forms
      # Note that alternative numerals XIIX and IIXX aren't handled
      assert Roman.decode("IIII", strict: false) == {:ok, 4}
      assert Roman.decode("VIIII", strict: false) == {:ok, 9}
      assert Roman.decode("IIIIII", strict: false) == {:ok, 6}
      assert Roman.decode("XXXXXX", strict: false) == {:ok, 60}
      assert Roman.decode("MDCCCCX", strict: false) == {:ok, 1910}
      assert Roman.decode("MDCDIII", strict: false) == {:ok, 1903}
    end
  end

  test "decode!/1 raises ArgumentError on invalid input" do
    assert_raise ArgumentError, fn -> Roman.decode!("VV") end
  end

  test "numeral?/1" do
    assert Roman.numeral?("XVI") == true
    assert Roman.numeral?("FOO") == false
    assert Roman.numeral?("x") == false
    assert Roman.numeral?("x", ignore_case: true) == true
  end

  test "numeral_pairs/1" do
    values = Enum.map(Roman.numeral_pairs, fn {val, _} -> val end)
    assert values == Enum.to_list(1..3999)
    assert [{1, "I"}, {2, "II"} | _] = Roman.numeral_pairs
  end

  describe "encode/1" do
    test "all valid numerals" do
      for int <- 1..3999 do
        expected = Converter.convert(int)
        {:ok, result} = Roman.encode(int)
        assert result == expected,
            "Expected encode(\"#{int}\") to yield #{expected}, but got #{result}"
      end
    end
  end

  test "encode!/1 raises ArgumentError on invalid input" do
    assert_raise ArgumentError, fn -> Roman.encode!(-1) end
  end
end

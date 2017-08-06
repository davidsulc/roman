defmodule Roman.DecoderTest do
  use ExUnit.Case, async: true

  alias Roman.Decoder
  alias Test.Support.Converter

  describe "validations" do
    test "empty string is invalid" do
      assert {:error, :empty_string, _} = Decoder.decode("")
    end

    test "IT is invalid" do
      assert {:error, :invalid_letter, _} = Decoder.decode("IT")
    end

    test "VIV is invalid" do
      assert {:error, :repeated_vld, _} = Decoder.decode("VIV")
    end

    test "IIII is invalid" do
      assert {:error, :identical_letter_seq_too_long, _} =
          Decoder.decode("IIII")
    end

    test "VX is invalid" do
      assert {:error, :sequence_increasing, _} = Decoder.decode("VX")
    end

    test "CMC is invalid" do
      assert {:error, :value_greater_than_subtraction, _} =
          Decoder.decode("CMC")
    end
  end

  test "decoding all valid numerals" do
    for num <- Test.Support.Converter.all_numerals do
      expected = Converter.convert(num)
      {:ok, result} = Decoder.decode(num)
      assert result == expected,
          "Expected decode(\"#{num}\") to yield #{expected}, but got #{result}"
    end
  end

  describe "decode!/1" do
    test "raises ArgumentError on invalid input" do
      assert_raise ArgumentError, fn ->
        Roman.decode!("VV")
      end
    end
  end
end

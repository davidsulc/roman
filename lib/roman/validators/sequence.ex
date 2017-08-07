defmodule Roman.Validators.Sequence do
  @moduledoc false

  @type sequence :: [Roman.Decoder.decoded_numeral]

  @doc """
  Validates that the sequence of decoded numerals.

  Runs all other validators defined in this module, returning the given
  sequence or `{:error, atom, message}` on validation failure.
  """
  @spec validate(Roman.decoded_numeral_sequence) ::
      Roman.decoded_numeral_sequence | Roman.error
  def validate(seq) do
    with  {:ok, seq} <- increasing_value_order(seq),
          {:ok, seq} <- subtraction_bounds_following_values(seq) do
      {:ok, seq}
    else
      {:error, _, _} = error -> error
    end
  end

  @doc """
  Validates that the sequence of decoded numerals doesn't increase in value.

  Returns the given sequence, or `{:error, :sequence_increasing, message}` on
  validation failure.

  ### Example

  iex> increasing_value_order([{"X", %{value: 10}}, {"I", %{value: 1}}])
  {:ok, [{"X", %{value: 10}}, {"I", %{value: 1}}]}
  iex> increasing_value_order([{"V", %{value: 5}}, {"X", %{value: 10}}])
  {:error, :sequence_increasing,
   "larger numerals must be placed to the left of smaller numerals, "
   <> "but encountered V (5) before X (10)"}
  """
  @spec increasing_value_order(Roman.decoded_numeral_sequence) ::
      {:ok, Roman.decoded_numeral_sequence} | Roman.error
  defp increasing_value_order(seq) when is_list(seq) do
    case check_increasing_value_order(seq) do
      :ok -> {:ok, seq}
      {:error, _, _} = error -> error
    end
  end

  @spec check_increasing_value_order(Roman.decoded_numeral_sequence)
      :: :ok | Roman.error
  defp check_increasing_value_order([]), do: :ok

  defp check_increasing_value_order([_]), do: :ok

  defp check_increasing_value_order([{_, %{value: a}},
      {_, %{value: b}} | _] = [_ | t]) when a >= b do
    check_increasing_value_order(t)
  end

  defp check_increasing_value_order([{num_l, %{value: val_l}},
      {num_r, %{value: val_r}} | _]) do
    {:error, :sequence_increasing,
      "larger numerals must be placed to the left of smaller numerals, but "
      <> "encountered #{num_l} (#{val_l}) before #{num_r} (#{val_r})"}
  end

  @doc """
  Validates that the sequence of decoded numerals respects the subtraction
  upper bound.

  Once a value has been subtracted from another, no further numeral or pair may
  match or exceed the subtracted value. This disallows values such as MCMD or
  CMC.

  Returns the given sequence, or `{:error, :value_greater_than_subtraction,
  message}` on validation failure.

  ### Example

  iex> subtraction_bounds_following_values([{"XC", %{value: 90, delta: 10}},
  ...>   {"IX", %{value: 9, delta: 1}}])
  {:ok, [{"XC", %{value: 90, delta: 10}}, {"IX", %{value: 9, delta: 1}}]}
  iex> subtraction_bounds_following_values([{"CM", %{value: 900, delta: 100}},
  ...>   {"C", %{value: 100}}])
  {:error, :value_greater_than_subtraction,
   "once a value has been subtracted from another, no further numeral or pair "
   <> "may match or exceed the subtracted value, but encountered C (100) after "
   <> "having previously subtracted 100 (in CM)"}
  """
  @spec subtraction_bounds_following_values(Roman.decoded_numeral_sequence)
      :: {:ok, Roman.decoded_numeral_sequence} | Roman.error
  defp subtraction_bounds_following_values(seq) do
    case check_subtraction_bound(seq, nil) do
      :ok -> {:ok, seq}
      {:error, _, _} = error -> error
    end
  end

  @spec check_subtraction_bound(Roman.decoded_numeral_sequence,
      nil | {number, Roman.numeral}) :: :ok | Roman.error
  defp check_subtraction_bound([], _), do: :ok

  defp check_subtraction_bound([{num, %{delta: d}} | t], nil) do
    check_subtraction_bound(t, {d, num})
  end

  defp check_subtraction_bound([_ | t], nil) do
    check_subtraction_bound(t, nil)
  end

  defp check_subtraction_bound([{n, %{value: v, delta: d}} | t], {delta, _})
      when v < delta do
    check_subtraction_bound(t, {d, n})
  end

  defp check_subtraction_bound([{_, %{value: v}} | t], {delta, _} = acc)
      when v < delta do
    check_subtraction_bound(t, acc)
  end

  defp check_subtraction_bound([{num, %{value: v}} | _], {delta, delta_num})
      when v >= delta do
    {:error, :value_greater_than_subtraction,
      "once a value has been subtracted from another, no further numeral or "
      <> "pair may match or exceed the subtracted value, but encountered "
      <> "#{num} (#{v}) after having previously subtracted #{delta} "
      <> "(in #{delta_num})"}
  end
end

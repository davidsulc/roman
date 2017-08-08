# Changelog

## 0.1.1

Added a `strict: boolean` option to `Roman.decode/2`:

```elixir
iex> Roman.decode("IIII", strict: false)
{:ok, 4}
```

Hid `Roman.numeral_pairs/0` from API by disabling docs.

## 0.1.0

Initial release

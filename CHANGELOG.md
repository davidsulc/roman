# Changelog

## 0.2.0

Added `:explain` option to decoder (default `false`)

Changed error format to `{:error, reason}` with `reason` having format
`{atom, messages}`

Added a `strict: boolean` option to `Roman.decode/2`:

```elixir
iex> Roman.decode("IIII", strict: false)
{:ok, 4}
```

Hid `Roman.numeral_pairs/0` from API by disabling docs.

## 0.1.0

Initial release

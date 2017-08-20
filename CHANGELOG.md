# Changelog

## 0.2.0

### Breaking changes

Decoding now has `explain: false` as default value (see docs)

Changed error format to `{:error, reason}` with `reason` having format
`{atom, messages}`


### Options for Roman.decode/2

Added `:explain` option to decoder (default `false`)

Added a `strict: boolean` option to `Roman.decode/2`:

```elixir
iex> Roman.decode("IIII", strict: false)
{:ok, 4}
```

Added `:zero` option to decoder to enable decoding "N" as 0

```elixir
iex> Roman.decode("N", zero: true)
{:ok, 0}
```

### Misc

Hid `Roman.numeral_pairs/0` from API by disabling docs.

Changed type name `Roman.error_atom` to `Roman.error_tuple`

## 0.1.0

Initial release

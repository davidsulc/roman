# Roman

A production-ready encoder/decoder for roman numerals, with detailed validation.

## Installation

The package can be installed by adding `roman` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:roman, "~> 0.2"}]
end
```

The docs can be found online at
[https://hexdocs.pm/roman](https://hexdocs.pm/roman).

## Basic Usage

```elixir
iex>Roman.numeral?("III")
true

iex> Roman.decode("MMMDCCCXCVIII")
{:ok, 3898}
iex> Roman.decode("ix", ignore_case: true)
{:ok, 9}
iex> Roman.decode!("XVI")
16
iex> Roman.decode("CMC", explain: true)
{:error, {:value_greater_than_subtraction, "once a value has been subtracted
  from another, no further numeral or pair may match or exceed the subtracted
  value, but encountered C (100) after having previously subtracted
  100 (in CM)"}}

iex> Roman.encode(16)
{:ok, "XVI"}
iex> Roman.encode!(16)
"XVI"
```

## Alternative Forms

`Roman` can handle [alternative forms](https://en.wikipedia.org/wiki/Roman_numerals#Alternative_forms)
and differentiate them. For example, by default decoding VXL will return an error (since 45 should be
encoded as XLV). However, the `:strict` option can be set to `false` to accept decoding alternative forms:

```elixir
iex> Roman.decode("VXL")
{:error, {:invalid_numeral, "numeral is invalid"}}

iex> Roman.decode("VXL", strict: false)
{:ok, 45}
```

Other libraries typically won't differentiate between VXL and XLV, considering both equally valid.
Composition rules are documented [here](composition_rules.html).

## Author

David Sulc


## License

Roman is released under the MIT License. See the LICENSE file for further
details.

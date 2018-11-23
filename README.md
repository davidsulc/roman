# Roman

A production-ready encoder/decoder for roman numerals, with detailed validation.

## Installation

<!-- If [available in Hex](https://hex.pm/docs/publish) (**NOT YET THE CASE!**),
the package can be installed
by adding `roman` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:roman, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/roman](https://hexdocs.pm/roman). -->

This package isn't yet available in Hex, but can still be installed
by adding `roman` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:roman, github: "davidsulc/roman", tag: "0.2.0"}]
end
```

Then, run `mix deps.get` to download and install.

## Documentation

Documentation can be generated locally with
[ExDoc](https://github.com/elixir-lang/ex_doc) using the `mix docs` command.
Once generated, the docs can be accessed by opening `doc/index.html`.

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

defmodule Roman.Mixfile do
  use Mix.Project

  @version "0.2.1"

  def project do
    [
      app: :roman,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    []
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    A roman numeral encoder/decoder that is aware of composition rules.
    """
  end

  defp package() do
    [
      maintainers: ["David Sulc"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/davidsulc/roman"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md": [filename: "readme", title: "Readme"],
        "pages/composition_rules.md": []
      ]
    ]
  end
end

defmodule SuffixTree.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :listing_engine,
      version: @version,
      elixir: "~> 1.16.2",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_options: [warnings_as_errors: true],
      deps: deps(),
      docs: docs()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.0"},
      {:joken_jwks, "~> 1.6"},
      {:math, "~> 0.7.0"},
      {:mock, "~> 0.3.8"}
    ]
  end

  defp docs do
    [
      main: SuffixTree,
      source_ref: "v#{@version}",
      source_url: "https://github.com/bnbfinder/listing_engine",
      groups_for_modules: [
        # Core: []
      ]
    ]
  end
end

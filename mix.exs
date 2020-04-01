defmodule Pipelines.MixProject do
  use Mix.Project

  def project do
    [
      app: :pipelines,
      version: "0.0.3",
      elixir: "~> 1.9",
      package: package(),
      description: description(),
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [extras: ["README.md", "CONTRIBUTING.md"]]
  end

  defp description do
    "A simple DSL to help you with the implementation of Railway Oriented Programming"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Vinnie Franco"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/vinniefranco/pipelines"}
    ]
  end
end

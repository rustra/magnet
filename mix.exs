defmodule Magnet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :magnet,
      version: "0.1.0",
      elixir: "~> 1.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description do
    """
    A Magnet URI encoder and decoder.
    """
  end

  def package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["rustra"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/rustra/magnet",
        "Issues" => "https://github.com/rustra/magnet/issues",
        "Contributors" => "https://github.com/rustra/magnet/graphs/contributors"
      }
    ]
  end

  def application do
    [
      applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end

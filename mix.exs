defmodule Magnet.Mixfile do
  use Mix.Project

  def project do
    [app: :magnet,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  defp description do
    """
    A magnet-uri encoder and decoder
    """
  end

  def package do
    [files: ["lib", "mix.exs", "README*", "LICENSE"],
     maintainers: ["Martin Gausby"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/gausby/magnet",
              "Issues" => "https://github.com/gausby/magnet/issues",
              "Contributors" => "https://github.com/gausby/magnet/graphs/contributors"}]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end

defmodule Magnet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :magnet,
      version: "0.0.1",
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
      maintainers: ["Martin Gausby", "rustra"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/gausby/magnet",
        "Issues" => "https://github.com/gausby/magnet/issues",
        "Contributors" => "https://github.com/gausby/magnet/graphs/contributors"
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
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false}
    ]
  end
end

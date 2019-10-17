defmodule Workplace2Slack.MixProject do
  use Mix.Project

  def project do
    [
      app: :workplace2slack,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mnesia],
      mod: {Workplace2Slack.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.6"},
      {:honeydew, "~> 1.4"},
    ]
  end
end

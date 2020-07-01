defmodule NotesAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :notes_api,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        notes_api: [
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  # run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :httpoison],
      mod: {NotesAPI.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:everex, git: "https://github.com/gmassman/everex.git", tag: "v0.1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:oauther, "~> 1.1"},
      {:httpoison, "~> 1.6"},
      {:git_cli, "~> 0.3"},
      {:erlport, "~> 0.10.1"},
    ]
  end
end

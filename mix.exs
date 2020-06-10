defmodule NotesAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :notes_api,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {NotesAPI.Application, []}
      #applications: [:everex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:everex, path: "/media/parsley/home/garrett/elixir/everex"},
      {:plug_cowboy, "~> 2.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

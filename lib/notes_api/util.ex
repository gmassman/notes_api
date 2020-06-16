defmodule NotesAPI.Util do
  def template_file(eex) do
    ["../templates", eex]
    |> Path.join
    |> Path.expand(__ENV__.file)
  end

  def results_path(host) do
    if Mix.env() == :prod do
      "https://#{host}/results"
    else
      "http://#{host}:#{Application.get_env(:notes_api, :port)}/results"
    end
  end
end

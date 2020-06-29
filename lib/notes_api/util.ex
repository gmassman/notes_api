defmodule NotesAPI.Util do
  @app_env Application.get_env(:notes_api, :environment)
  @prod_server "notes.garrettmassman.com"

  def template_file(eex) do
    ["../templates", eex]
    |> Path.join
    |> Path.expand(__ENV__.file)
  end

  def hostname() do
    if @app_env == :prod do
      "https://#{@prod_server}"
    else
      "http://localhost:#{Application.get_env(:notes_api, :port)}"
    end
  end
end

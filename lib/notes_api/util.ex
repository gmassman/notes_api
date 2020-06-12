defmodule NotesAPI.Util do
  def template_file(eex) do
    ["../templates", eex]
    |> Path.join
    |> Path.expand(__ENV__.file)
  end
end

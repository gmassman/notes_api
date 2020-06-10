defmodule NotesAPI.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  require Logger
  use Plug.Router

  def init(_opts) do
    Logger.info("server starting at http://localhost:#{Application.get_env(:notes_api, :port)}")
  end

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "<h1>Welcome!</h1>")
  end

  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end 
end


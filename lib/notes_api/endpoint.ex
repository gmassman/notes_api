defmodule NotesAPI.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  use Plug.Router

  plug :match
  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded]
  plug Plug.Session, store: :ets, key: "_notes_api_session", table: :session
  plug :dispatch

  get "/", do: NotesAPI.Login.view_index(conn)
  post "/", do: NotesAPI.Login.handle_index(conn)
  get "/oauth", do: NotesAPI.OAuth.get_evernote_login(conn)
  get "/oauth_callback", do: NotesAPI.OAuth.callback(conn)
  get "/results", do: NotesAPI.OAuth.results(conn)

  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end 
end


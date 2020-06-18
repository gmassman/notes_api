defmodule NotesAPI.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  use Plug.Router

  plug NotesAPI.Plugs
  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded]
  plug Plug.Session, store: :cookie,
                     key: "_notes_api_session",
                     encryption_salt: Application.get_env(:notes_api, :encryption_salt),
                     signing_salt: Application.get_env(:notes_api, :signing_salt),
                     key_length: 64,
                     log: :debug
  plug :fetch_session
  plug :match
  plug :dispatch

  get "/", do: NotesAPI.Login.view_index(conn)
  post "/", do: NotesAPI.Login.handle_index(conn)
  get "/oauth", do: NotesAPI.OAuth.get_evernote_login(conn)
  get "/oauth_callback", do: NotesAPI.OAuth.callback(conn)
  get "/dashboard", do: NotesAPI.Dashboard.dashboard(conn)
  get "/logout", do: NotesAPI.Dashboard.logout(conn)

  match _ do
    send_resp(conn, 404, "")
  end 
end


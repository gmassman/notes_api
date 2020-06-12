defmodule NotesAPI.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  alias NotesAPI.Util
  require Logger
  use Plug.Router

  def init(_opts) do
    Logger.info("server starting at http://localhost:#{Application.get_env(:notes_api, :port)}")
  end

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "login.eex" |> Util.template_file |> EEx.eval_file)
  end

  post "/" do
    case check_login(conn.params) do
      true -> send_resp(conn, 200, "verified")
      _ -> send_resp(conn, 204, "")
    end
  end

  def check_login(%{"login_token" => login_token} = _params) do
    env_token = Application.get_env(:notes_api, :login_token)
    env_token && login_token == env_token
  end
  def check_login(_), do: false

  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end 
end


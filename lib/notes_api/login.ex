defmodule NotesAPI.Login do
  import Plug.Conn
  alias NotesAPI.Util

  def view_index(conn, _params \\ []) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "login.eex" |> Util.template_file |> EEx.eval_file)
  end

  def handle_index(conn, _params \\ []) do
    case check_login(conn.params) do
      true ->
        send_resp(conn, 200, "load_oauth.eex" |> Util.template_file |> EEx.eval_file)
      _ ->
        send_resp(conn, 204, "")
    end
  end

  defp check_login(%{"login_token" => login_token} = _params) do
    env_token = Application.get_env(:notes_api, :login_token)
    env_token && login_token == env_token
  end
  defp check_login(_), do: false
end

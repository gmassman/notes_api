defmodule NotesAPI.Dashboard do
  alias NotesAPI.Util
  import Plug.Conn

  def dashboard(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "dashboard.eex"
                      |> Util.template_file
                      |> EEx.eval_file(oauth_results: get_session(conn, :oauth_results)))
  end
  
  def logout(conn) do
    conn
    |> clear_session()
    |> put_resp_header("Location", "/")
    |> send_resp(302, "")
  end
end

defmodule NotesAPI.OAuth do
  @prod_domain "www.evernote.com"
  @sandbox_domain "sandbox.evernote.com"
  @use_en_sandbox Application.get_env(:notes_api, :en_sandbox)
  @default_oauth_opts [
    consumer_key: Application.get_env(:notes_api, :en_oauth_key),
    consumer_secret: Application.get_env(:notes_api, :en_oauth_secret),
    method: :plaintext
  ]

  alias NotesAPI.Util
  import Plug.Conn

  def get_evernote_login(conn) do
    authorization_url = "#{base_oauth_url()}/OAuth.action?oauth_token=#{temp_token(conn.host)}"

    conn
    |> put_resp_header("Location", authorization_url)
    |> send_resp(302, "")
  end

  def callback(conn) do
    oauth_results = fetch_oauth_results(conn.params["oauth_token"], conn.params["oauth_verifier"])

    conn
    |> put_session(:oauth_results, oauth_results)
    |> put_resp_header("Location", Util.dashboard_path(conn.host))
    |> send_resp(302, "")
  end

  defp base_oauth_url() do
    if @use_en_sandbox do
      "https://#{@sandbox_domain}"
    else
      "https://#{@prod_domain}"
    end
  end

  defp oauth_credentials(opts \\ []) do
    options = Keyword.merge(@default_oauth_opts, opts)
    OAuther.credentials(options)
  end

  defp request_oauth_body(oauth_creds, oauth_params) do
    url = "#{base_oauth_url()}/oauth"
    signed_params = OAuther.sign("get", url, oauth_params, oauth_creds)
    {auth_header, params} = OAuther.header(signed_params)

    response = HTTPoison.get!(url, [auth_header], params)

    response.body
    |> String.split("&")
    |> Enum.into(%{}, fn x ->
      String.split(x, "=")
      |> List.to_tuple
    end)
  end

  defp temp_token(host) do
    oauth_credentials()
    |> request_oauth_body([{"oauth_callback", "http://#{host}:#{Application.get_env(:notes_api, :port)}/oauth_callback"}])
    |> Map.fetch!("oauth_token")
  end

  defp fetch_oauth_results(token, verifier) do
    oauth_credentials(token: token)
    |> request_oauth_body([{"oauth_verifier", verifier}])
    |> Enum.into(%{}, fn {k, v} ->
      {k, URI.decode(v)}
    end)
  end
end


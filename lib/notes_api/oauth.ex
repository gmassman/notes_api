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
    IO.inspect(@use_en_sandbox, label: "using sandbox?")
    authorization_url = "#{base_oauth_url()}/OAuth.action?oauth_token=#{temp_token(conn.host)}"

    conn
    |> put_resp_header("Location", authorization_url)
    |> send_resp(302, "")
  end

  def callback(conn) do
    results = access_token(conn.params["oauth_token"], conn.params["oauth_verifier"])
    _session = fetch_session(conn)

    conn
    |> put_session(:results, results)
    |> put_resp_header("Location", "https://#{conn.host}/results")
    |> send_resp(302, "")
  end

  def results(conn) do
    session = fetch_session(conn)
    
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "results.eex"
                      |> Util.template_file
                      |> EEx.eval_file(results: session[:results]))
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

  defp access_token(token, verifier) do
    oauth_credentials(token: token)
    |> request_oauth_body([{"oauth_verifier", verifier}])
    |> Enum.into(%{}, fn {k, v} ->
      {k, URI.decode(v)}
    end)
  end
end

#defmodule Everex.OAuth.Client do

  #@production_server "www.evernote.com"
  #@sandbox_server "sandbox.evernote.com"

  #defstruct server: nil

  #defmodule Request do
    #defstruct url: nil, headers: nil, params: nil
  #end

  #def new(opts \\ []) do
    #srv = case opts[:sandbox] do
      #true -> @sandbox_server
      #_else -> @production_server
    #end
    #state = %__MODULE__{server: srv}
  #end

  #def make_authorization_url(temp_token) do
    #url = "https://sandbox.evernote.com/OAuth.action?oauth_token="
    #url <> temp_token
  #end

  #def request_temporary_token(client = %__MODULE__{server: srv}) do
    #oauth_creds = OAuther.credentials([
      #consumer_key: System.get_env("EN_CONSUMER_KEY"),
      #consumer_secret: System.get_env("EN_CONSUMER_SECRET"),
      #method: :plaintext,
      #])

    #req_params = [{"oauth_callback", "http://localhost:4000/oauth_callback"}]
    #req_url = "https://#{srv}/oauth"

    #req = sign_request("get", req_url, req_params, oauth_creds)
    #response = HTTPoison.get!(req.url, req.headers, req.params)

    #response.body |> String.split("&") |> Enum.into(
      #%{}, fn x -> String.split(x, "=") |> List.to_tuple end
    #) |> Map.fetch!("oauth_token")
  #end

  #def request_final_token(client = %__MODULE__{server: srv}, token,
                          #verifier)
  #do
    #oauth_creds = OAuther.credentials([
      #consumer_key: System.get_env("EN_CONSUMER_KEY"),
      #consumer_secret: System.get_env("EN_CONSUMER_SECRET"),
      #token: token,
      #method: :plaintext,
      #])

    #req_params = [{"oauth_verifier", verifier}]
    #req_url = "https://#{srv}/oauth"

    #req = sign_request("get", req_url, req_params, oauth_creds)
    #response = HTTPoison.get!(req.url, req.headers, req.params)

    #response.body |> String.split("&") |> Enum.into(
      #%{}, fn x -> String.split(x, "=") |> List.to_tuple end
      #)
  #end

  #def sign_request(action, url, params, oauth_creds) do
    #signed_params = OAuther.sign(action, url, params, oauth_creds)
    #{auth_header, params} = OAuther.header(signed_params)
    #%Request{url: url, headers: [auth_header], params: params}
  #end
#end

#defmodule Everex.OAuth.CallbackHandler do
  #alias Everex.OAuth
  #use Plug.Router

  #def start do
    #Plug.Cowboy.http(__MODULE__, nil, port: 4000)
  #end

  #def shutdown do
    #Plug.Cowboy.shutdown(OAuth.CallbackHandler.HTTP)
  #end

  #plug Plug.Logger
  #plug :match
  #plug :dispatch

  #get "/oauth_callback" do
    #conn
    #|> Plug.Conn.fetch_query_params
    #|> process_params
    #|> respond
    #shutdown()
  #end

  #match _ do
    #send_resp(conn, 404, "Nothing to see here.")
  #end

  #def process_params(conn) do
    #client = OAuth.Client.new(sandbox: true)
    #result = OAuth.Client.request_final_token(
      #client,
      #conn.params["oauth_token"],
      #conn.params["oauth_verifier"]
    #) |> decode_result
    #File.write!(".en_auth", :erlang.term_to_binary(result))
    #Plug.Conn.assign(conn, :response, """
    #<html><body>
    #<p>You have successfully granted access to your Evernote account:</p>
    #<p><code>#{inspect(result)}</code></p>
    #<p>The token has been stored in ".en_auth".</p>
    #</body></html>
    #""")
  #end

  #def decode_result(result) do
    #Enum.map(result, fn {k,v} -> {k, URI.decode(v)} end)
    #|> Enum.into(%{})
  #end

  #def respond(conn) do
    #conn
    #|> Plug.Conn.put_resp_content_type("text/html")
    #|> Plug.Conn.send_resp(200, conn.assigns[:response])
  #end
#end

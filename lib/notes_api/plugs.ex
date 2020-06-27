defmodule NotesAPI.Plugs do
  def init(opts), do: opts

  def call(conn, _opts) do
    put_in(conn.secret_key_base, Application.get_env(:notes_api, :secret_key_base))
  end
end

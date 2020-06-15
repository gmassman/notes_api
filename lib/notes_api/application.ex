defmodule NotesAPI.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: NotesAPI.Endpoint,
        options: [
          port: Application.get_env(:notes_api, :port)
        ]
      )
    ]

    Logger.info("server starting at http://localhost:#{Application.get_env(:notes_api, :port)}")
    
    opts = [strategy: :one_for_one, name: NotesAPI.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

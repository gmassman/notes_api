defmodule NotesAPI.Application do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: NotesAPI.Endpoint,
        options: [
          port: Application.get_env(:notes_api, :port) |> String.to_integer
        ]
      )
    ]

    opts = [strategy: :one_for_one, name: NotesAPI.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

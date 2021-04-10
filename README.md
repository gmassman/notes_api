# NotesAPI

Download the latest code on the server, then from the app directory run these commands:
```
MIX_ENV=prod mix release --path ~/notes_api_release
cd ~/notes_api_release && bin/notes_api start_iex
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `notes_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:notes_api, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/notes_api](https://hexdocs.pm/notes_api).


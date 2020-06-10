use Mix.Config

config :notes_api, port: System.get_env("APP_PORT", "4444")
config :logger, level: :info

use Mix.Config

config :notes_api, port: System.get_env("APP_PORT", "4444")
config :notes_api, en_oauth_key: System.get_env("EN_OAUTH_KEY", "")
config :notes_api, en_oauth_secret: System.get_env("EN_OAUTH_SECRET", "")
config :notes_api, en_access_token: System.get_env("EN_ACCESS_TOKEN", "")
config :notes_api, login_token: System.get_env("LOGIN_TOKEN", nil)

config :logger, level: :info

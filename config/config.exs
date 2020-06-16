use Mix.Config

config :notes_api, port: String.to_integer(System.get_env("APP_PORT", "4444"))
config :notes_api, en_sandbox: System.get_env("EN_SANDBOX", nil)
config :notes_api, en_oauth_key: System.get_env("EN_OAUTH_KEY", "")
config :notes_api, en_oauth_secret: System.get_env("EN_OAUTH_SECRET", "")
config :notes_api, en_access_token: System.get_env("EN_ACCESS_TOKEN", "")
config :notes_api, login_token: System.get_env("LOGIN_TOKEN", nil)
config :notes_api, secret_key_base: System.get_env("SECRET_KEY_BASE", "")
config :notes_api, encryption_salt: System.get_env("ENCRYPTION_SALT", "")
config :notes_api, signing_salt: System.get_env("SIGNING_SALT", "")

config :logger, level: :info

import Config

# Configures the endpoint
config :workplace2slack,
  slack_token: System.get_env("SLACK_TOKEN", "slack_token_not_provided"),
  fb_app_secret: System.get_env("FB_APP_SECRET", "fb_app_secret_not_provided")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"

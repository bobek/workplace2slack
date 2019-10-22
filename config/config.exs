import Config

# Configures the endpoint
config :workplace2slack,
  slack_token: System.fetch_env!("SLACK_TOKEN"),
  fb_app_secret: System.fetch_env!("FB_APP_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"

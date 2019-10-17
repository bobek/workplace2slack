use Mix.Config

# Configures the endpoint
config :workplace2slack,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  slack_token: "xoxp-582148963089-605486615847-785409687250-6a4d6ec19e5b322c47c50fd1f4b28858"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"

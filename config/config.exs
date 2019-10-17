use Mix.Config

# Configures the endpoint
config :workplace2slack,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__)

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"

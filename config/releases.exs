import Config

config :workplace2slack,
  port: String.to_integer(System.fetch_env!("PORT")),
  slack_token: System.fetch_env!("SLACK_TOKEN"),
  fb_app_secret: System.fetch_env!("FB_APP_SECRET")

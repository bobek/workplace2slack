defmodule Workplace2Slack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Workplace2Slack.Worker.start_link(arg)
      # {Workplace2Slack.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Workplace2Slack.Router, options: [port: Application.get_env(:workplace2slack, :port, 4000)]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Workplace2Slack.Supervisor]
    {:ok, supervisor} = Supervisor.start_link(children, opts)

    :ok = Honeydew.start_queue(:slack)
    :ok = Honeydew.start_workers(:slack, {Workplace2Slack.SlackWorker, [Application.get_env(:workplace2slack, :slack_token, "")]})

    {:ok, supervisor}
  end
end

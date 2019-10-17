defmodule Workplace2slack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Workplace2slack.Worker.start_link(arg)
      # {Workplace2slack.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Workplace2slack.Router, options: [port: 4000]},
    ]

    :ok = Honeydew.start_queue(:slack)
    :ok = Honeydew.start_workers(:slack, {Workplace2slack.SlackWorker, [Application.get_env(:workplace2slack, :slack_token, ""), "CP3C0HB26"]})

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Workplace2slack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Workplace2Slack.SlackWorker do
  @behaviour Honeydew.Worker

  def init([token, default_channel]) do
    {:ok, %{
              token: token,
              default_channel: default_channel,
            }}
  end

  def send_message(msg, state) do
    body = Jason.encode!(msg)
    IO.inspect body

    post_message =
    with url <- Application.get_env(:slack, :url, "https://slack.com") <> "/api/chat.postMessage",
         headers <- [{"content-type", "application/json; charset=utf-8"}, {"authorization", "Bearer #{state.token}"}] do
      HTTPoison.post(url, body, headers)
    end

    IO.inspect post_message
  end
end

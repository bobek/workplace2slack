defmodule Workplace2Slack.SlackWorker do
  @behaviour Honeydew.Worker
  require Logger

  def init([token]) do
    {:ok, %{
              token: token,
            }}
  end

  def send_message(msg, request_id, state) do
    Logger.metadata(request_id: request_id)

    body = Jason.encode!(msg)

    post_message =
    with url <- Application.get_env(:slack, :url, "https://slack.com") <> "/api/chat.postMessage",
         headers <- [{"content-type", "application/json; charset=utf-8"}, {"authorization", "Bearer #{state.token}"}] do
      HTTPoison.post(url, body, headers)
    end

    Logger.info("sent to Slack")
  end
end

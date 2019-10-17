defmodule Workplace2Slack.Router do
  use Plug.Router
  alias Workplace2Slack.Workplace
  require Logger

  plug :match
  plug Plug.RequestId
  plug Plug.Logger
  plug Plug.Parsers,
    parsers: [:json, :urlencoded],
    body_reader: {Workplace2Slack.Plug.CacheBodyReader, :read_body, []},
    json_decoder: Jason
  plug :dispatch

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  get "/workplace" do
    IO.inspect conn
    case conn.query_params["hub.challenge"] do
      nil -> send_resp(conn, 200, "OK")
      challange when challange > 0 -> send_resp(conn, 200, challange)
      _ -> send_resp(conn, 200, "OKK")
    end
  end

  post "/workplace" do
    Workplace2Slack.HubSignature.validate_request!(conn)

    with %{"entry" => [%{"changes" => [change|_]}|_], "object" => "group"} <- conn.body_params,
         %{"field" => "posts", "value" => %{"community" => %{"id" => _community_id}, "from" => %{"name" => author}, "message" => message, "permalink_url" => permalink_url}} <- change do

      attachment_urls = case change do
        %{"field" => "posts", "value" => %{ "attachments" => %{"data" => attachments}}} -> Enum.flat_map(attachments, fn x -> Workplace.extract_image_url(x) end)
        _ -> []
      end
      images = attachment_urls
      |> List.flatten
      |> Enum.map(fn x -> %{type: "image", image_url: x, alt_text: "image"} end)

      slack_msg =
      %{
        as_user: false,
        channel: "CP3C0HB26",
        link_names: true,
        parse: "full",
        blocks: [
          %{
            type: "section",
            text: %{
              type: "mrkdwn",
              text: "New post from #{author} - #{permalink_url}",
            },
          },
          %{
            type: "section",
            text: %{
              type: "mrkdwn",
              text: Workplace.sanitize_message(message)
            },
           } | images ],
      }

      Logger.info("#{permalink_url} by #{author}")
      {:send_message, [slack_msg, Logger.metadata()[:request_id]]} |> Honeydew.async(:slack)
    end

    send_resp(conn, 201, "OK")
  end

  match _ do
    IO.inspect conn
    send_resp(conn, 404, "not found")
  end
end

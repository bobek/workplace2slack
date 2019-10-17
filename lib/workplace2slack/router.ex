defmodule Workplace2slack.Router do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason
  plug :dispatch

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  get "/workplace" do
    IO.inspect conn.query_params
    IO.inspect conn.body_params
    case conn.query_params["hub.challenge"] do
      nil -> send_resp(conn, 200, "OK")
      challange when challange > 0 -> send_resp(conn, 200, challange)
      _ -> send_resp(conn, 200, "OKK")
    end
  end

  post "/workplace" do
    with %{"entry" => [%{"object" => "group", "changes" => [change|_]}]} <- conn.body_params,
         %{"field" => "posts", "value" => %{"community" => %{"id" => community_id, "message" => message, "permalink_url" => permalink_url}}} <- change do

      IO.inspect community_id
      IO.inspect permalink_url
      IO.inspect message

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
              text: message,
              },
          },
        ],
      }

      {:send_message, [slack_msg]} |> Honeydew.async(:slack)
    end

    send_resp(conn, 201, "OK")
  end

  match _ do
    IO.inspect conn
    send_resp(conn, 404, "not found")
  end
end

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

  def extract_image_url(%{"media" => %{"image" => %{"src" => src}}, "type" => "photo"}), do: [src]
  def extract_image_url(%{"subattachments" => %{"data" => data}}), do: Enum.flat_map(data, fn x -> extract_image_url(x) end)
  def extract_image_url(_), do: []

  def truncate(text, opts \\ []) do
    max_length  = opts[:max_length] || 50
    omission    = opts[:omission] || "..."

    cond do
      not String.valid?(text) ->
        text
      String.length(text) < max_length ->
        text
      true ->
        length_with_omission = max_length - String.length(omission)

        "#{String.slice(text, 0, length_with_omission)}#{omission}"
    end
  end

  post "/workplace" do
    IO.puts "Received message from FB"

    with %{"entry" => [%{"changes" => [change|_]}|_], "object" => "group"} <- conn.body_params,
         %{"field" => "posts", "value" => %{"community" => %{"id" => _community_id}, "from" => %{"name" => author}, "message" => message, "permalink_url" => permalink_url}} <- change do

      attachment_urls = case change do
        %{"field" => "posts", "value" => %{ "attachments" => %{"data" => attachments}}} -> Enum.flat_map(attachments, fn x -> extract_image_url(x) end)
        _ -> []
      end
      IO.inspect attachment_urls

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
              text: truncate(message, max_length: 1567)
            },
           } | images ],
      }

      IO.inspect slack_msg
      {:send_message, [slack_msg]} |> Honeydew.async(:slack)
    end

    send_resp(conn, 201, "OK")
  end

  match _ do
    IO.inspect conn
    send_resp(conn, 404, "not found")
  end
end

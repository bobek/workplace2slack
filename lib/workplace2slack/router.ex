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

  match _ do
    send_resp(conn, 404, "not found")
  end
end

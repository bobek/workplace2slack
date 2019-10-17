defmodule Workplace2Slack.Plug.CacheBodyReader do
  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:body_raw], &[body | (&1 || [])])
    {:ok, body, conn}
  end
end

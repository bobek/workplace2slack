defmodule Workplace2Slack.HubSignature do
  import Plug.Conn

  def validate_request!(conn) do
    IO.puts("Validate request")

    {:ok, bdigest} = get_signature_digest(conn)
    IO.inspect(bdigest)
    {:ok, bsecret} = get_secret()
    IO.inspect(bsecret)
    {:ok} = valid_request?(bdigest, bsecret, conn)


    with {:ok, digest} <- get_signature_digest(conn),
         {:ok, secret} <- get_secret(),
         {:ok} <- valid_request?(digest, secret, conn)
    do
      IO.puts "x-hub-signature is valid"
      conn
    # else
    #   _ -> conn |> send_resp(401, "Could not Authenticate") |> halt()
    end
    conn
  end

  defp get_signature_digest(conn) do
    case get_req_header(conn, "x-hub-signature") do
      ["sha1=" <> digest] -> {:ok, digest}
      _ -> {:error, "No Signature Found"}
    end
  end

  defp get_secret do
    Application.get_env(:workplace2slack, :fb_app_secret)
  end

  defp valid_request?(digest, secret, conn) do
    hmac = :crypto.hmac(:sha, secret, conn.assigns.body_raw) |> Base.encode16(case: :lower)
    IO.puts("FB: #{digest}")
    IO.puts("OUR: #{hmac}")
    if Plug.Crypto.secure_compare(digest, hmac), do: {:ok}, else: {:error}
  end
end

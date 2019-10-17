defmodule Workplace2Slack.Workplace do
  def extract_image_url(%{"media" => %{"image" => %{"src" => src}}, "type" => "photo"}), do: [src]
  def extract_image_url(%{"subattachments" => %{"data" => data}}), do: Enum.flat_map(data, fn x -> extract_image_url(x) end)
  def extract_image_url(_), do: []

  def sanitize_message(msg), do: truncate(msg)

  defp truncate(text, opts \\ []) do
    max_length  = opts[:max_length] || 1567
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
end

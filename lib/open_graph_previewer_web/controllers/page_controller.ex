defmodule OpenGraphPreviewerWeb.PageController do
  use OpenGraphPreviewerWeb, :controller

  alias OpenGraphPreviewer.Url, as: Url

  @doc """
  Default landing page
  """
  @spec home(Plug.Conn.t(), any) :: Plug.Conn.t()
  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  @doc """
  If a URL is present in the params, use it to
  check the DB for an existing row, if not hit GET request to retrieve image
  """
  @spec url(Plug.Conn.t(), Map.t()) :: Plug.Conn.t()
  def url(conn, %{"url" => url}) do
    image =
      if valid_url?(url) do
        case Url.get(url) do
          nil ->
            {:ok, stored_url} = Url.insert(%{url: url, status: "processing"})
            image_handler(url, stored_url)

          %{image: url_image} ->
            url_image
        end
      else
        nil
      end

    render(conn, :home, layout: false, url: url, image: image)
  end

  @doc """
  Takes 'conn' and 'params' as arguments
  Assigns image if available, otherwise return to homepage
  """
  @spec submit(Plug.Conn.t(), Map.t()) :: Plug.Conn.t()
  def submit(conn, %{"params" => %{"url" => ""}}) do
    redirect(conn, to: ~p"/")
  end

  def submit(conn, %{"params" => %{"url" => url}}) do
    case valid_url?(url) do
      true ->
        {:ok, stored_url} =
          case Url.get(url) do
            nil -> Url.insert(%{url: url, status: "processing"})
            stored_url -> {:ok, stored_url}
          end

        Task.async(fn ->
          image_handler(url, stored_url)
        end)

        conn
        |> redirect(to: ~p"/url/#{url}")

      false ->
        conn
        |> put_flash(:error, "URL malformed, please try again.")
        |> redirect(to: ~p"/")
    end
  end

  @doc """
  Look up by URL, poll status, stop polling when status is "done"
  """
  @spec poll_status(Plug.Conn.t(), Map.t()) :: %{}
  def poll_status(conn, %{"url" => url}) do
    case Url.get(url) do
      %Url{status: "done", image: image} -> json(conn, %{status: "done", image: image})
      _ -> json(conn, %{status: "processing", image: nil})
    end
  end

  ###########
  # Private #
  ###########

  @spec image_handler(String.t(), %Url{}) :: String.t() | nil
  defp image_handler(url, stored_url) do
    image = fetch_image_from_url(url)

    case Url.update(stored_url, %{image: image, status: "done"}) do
      {:ok, %{image: stored_image}} -> stored_image
      {:error, _} -> image
    end
  end

  @spec fetch_image_from_url(String.t()) :: String.t() | nil
  defp fetch_image_from_url(nil), do: nil

  defp fetch_image_from_url(url) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 301, headers: headers}} ->
        # Sometimes the url data is "Location" or "location"
        # This is in place to remove that obstacle
        headers =
          headers
          |> Enum.into(%{})
          |> Map.new(fn {k, v} -> {String.downcase(k), v} end)

        new_url = Map.get(headers, "location")
        fetch_image_from_url(new_url)

      {:ok, %{body: body}} ->
        parse_image(body)

      _ ->
        nil
    end
  end

  @spec parse_image(String.t()) :: String.t() | nil
  defp parse_image(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("meta[property='og:image']")
    |> Floki.attribute("content")
    |> Enum.at(0)
  end

  @spec valid_url?(String.t()) :: Boolean.t()
  defp valid_url?(url) do
    regexp =
      ~r/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/

    Regex.match?(regexp, url)
  end
end

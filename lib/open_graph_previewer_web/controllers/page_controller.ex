defmodule OpenGraphPreviewerWeb.PageController do
  use OpenGraphPreviewerWeb, :controller

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
        image_handler(url)
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
        image_handler(url)

        conn
        |> redirect(to: ~p"/url/#{url}")

      false ->
        conn
        |> put_flash(:error, "URL malformed, please try again.")
        |> redirect(to: ~p"/")
    end
  end

  @doc """
  Take a 'url' string and fetch the image
  """
  @spec image_handler(String.t()) :: String.t() | nil
  defp image_handler(url) do
    image = fetch_image_from_url(url)
  end

  @doc """
  Fetch the og:image from the URL or return nil
  """
  @spec fetch_image_from_url(String.t()) :: String.t() | nil
  defp fetch_image_from_url(nil), do: nil

  defp fetch_image_from_url(url) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 301, headers: headers}} ->
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

  @doc """
  Extract the og:image content value from HTML body
  """
  @spec parse_image(String.t()) :: String.t() | nil
  defp parse_image(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("meta[property='og:image']")
    |> Floki.attribute("content")
    |> Enum.at(0)
  end

  @doc """
  Validate the formatting of the URL being passed in
  """
  @spec valid_url?(String.t()) :: Boolean.t()
  defp valid_url?(url) do
    regexp =
      ~r/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/

    Regex.match?(regexp, url)
  end
end

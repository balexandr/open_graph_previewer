defmodule OpenGraphPreviewerWeb.PageControllerTest do
  use OpenGraphPreviewerWeb.ConnCase

  alias OpenGraphPreviewer.Url, as: Url

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Open Graph Previewer"
  end

  test "GET /url/", %{conn: conn} do
    conn = get(conn, ~p"/url/")

    assert html_response(conn, 200) =~ "Open Graph Previewer"
  end

  test "GET /url/:url", %{conn: conn} do
    url = "https://www.redfin.com"
    conn = get(conn, ~p"/url/#{url}")

    assert conn.params == %{"url" => url}
  end

  test "GET /url/:url with existing DB row", %{conn: conn} do
    url = "https://www.redfin.com"
    image = "https://ssl.cdn-redfin.com/v484.2.0/images/logos/redfin-logo-square-red-1200.png"

    Url.insert(%{
      url: url,
      image: image,
      status: "done"
    })

    conn = get(conn, ~p"/url/#{url}")

    assert conn.assigns[:image] == image
  end

  test "POST /submit/ kicks off processing" do
    url = "https://www.redfin.com"

    post(build_conn(), "/submit", params: %{"url" => url})

    assert Url.get(url).status == "processing"
  end

  test "POST /submit/ with bad URL" do
    url = "redfin"

    conn = post(build_conn(), "/submit", params: %{"url" => url})

    assert conn.assigns[:flash] == %{"error" => "URL malformed, please try again."}
  end
end

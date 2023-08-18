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
  Takes 'conn' and 'params' as arguments
  Assigns image if available, otherwise return to homepage
  """
  @spec submit(Plug.Conn.t(), Map.t()) :: Plug.Conn.t()
  def submit(conn, %{"params" => %{"url" => ""}}) do
    redirect(conn, to: ~p"/")
  end

  def submit(conn, %{"params" => %{"url" => url}}) do
    render(conn, :home, layout: false)
  end
end

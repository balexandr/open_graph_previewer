defmodule OpenGraphPreviewer.Repo do
  use Ecto.Repo,
    otp_app: :open_graph_previewer,
    adapter: Ecto.Adapters.Postgres
end

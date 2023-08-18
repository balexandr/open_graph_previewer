defmodule OpenGraphPreviewer.Repo.Migrations.AddUrlTable do
  use Ecto.Migration

  def up do
    create table("urls", primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :url, :string
      add :image, :string
      add :status, :string

      timestamps()
    end

    create unique_index("urls", [:url])
  end

  def down do
    drop table("urls")
  end
end

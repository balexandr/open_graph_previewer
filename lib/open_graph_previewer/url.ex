defmodule OpenGraphPreviewer.Url do
  @moduledoc """
  Database schema for "urls" table
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias OpenGraphPreviewer.{Repo, Url}

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "urls" do
    field :url, :string
    field :image, :string
    field :status, :string

    timestamps()
  end

  @doc """
  Take 'params' as an argument and insert into 'urls' table
  """
  @spec insert(Map.t()) :: {:ok, %Url{} | {:error, Ecto.Changeset.t()}}
  def insert(params) do
    %Url{}
    |> changeset(params)
    |> Repo.insert()
  end

  @doc """
  Take existing %Url{} with 'params' as an argument and update 'urls' table
  """
  @spec update(%Url{}, Map.t()) :: {:ok, %Url{} | {:error, Ecto.Changeset.t()}}
  def update(url, params) do
    url
    |> changeset(params)
    |> Repo.update()
  end

  @doc """
  Take 'url' as an argument and get the table row
  """
  @spec get(String.t()) :: {:ok, %Url{} | {:error, Ecto.Changeset.t()}}
  def get(url) do
    Repo.get_by(Url, url: url)
  end

  @doc """
  Changeset to control params being sent to the database
  """
  @spec changeset(%Url{}, Map.t() | %{}) :: Ecto.Changeset.t()
  def changeset(url, params \\ %{}) do
    url
    |> cast(params, [:url, :image, :status])
    |> unique_constraint(:url)
  end
end

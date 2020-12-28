defmodule Listudy.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :slug}
  schema "posts" do
    field :body, :string
    field :published, :boolean, default: false
    field :slug, :string
    field :title, :string
    field :script, :string
    field :author_id, :id

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :body, :published, :script])
    |> validate_required([:title, :slug, :body, :published])
    |> unique_constraint(:title)
    |> unique_constraint(:slug)
  end
end

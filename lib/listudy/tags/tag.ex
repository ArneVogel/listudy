defmodule Listudy.Tags.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :description, :string
    field :slug, :string
    field :summary, :string
    field :title, :string
    field :name, :string

    has_many :book_tags, Listudy.BookTags.BookTag

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:title, :slug, :name, :summary, :description])
    |> validate_required([:title, :slug, :name, :summary, :description])
  end
end

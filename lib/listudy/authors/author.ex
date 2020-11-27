defmodule Listudy.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :description, :string
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
  end
end

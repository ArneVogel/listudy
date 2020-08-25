defmodule Listudy.Motifs.Motif do
  use Ecto.Schema
  import Ecto.Changeset

  schema "motifs" do
    field :description, :string
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(motif, attrs) do
    motif
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end

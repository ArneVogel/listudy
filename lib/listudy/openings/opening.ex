defmodule Listudy.Openings.Opening do
  use Ecto.Schema
  import Ecto.Changeset

  schema "openings" do
    field :description, :string
    field :eco, :string
    field :moves, :string
    field :name, :string
    field :slug, :string
    field :fen, :string
    field :uci_moves, :string

    timestamps()
  end

  @doc false
  def changeset(opening, attrs) do
    opening
    |> cast(attrs, [:name, :slug, :description, :eco, :moves, :fen, :uci_moves])
    |> validate_required([:name, :slug, :description, :eco, :moves, :fen, :uci_moves])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end

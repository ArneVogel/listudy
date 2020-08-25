defmodule Listudy.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :description, :string
    field :name, :string
    field :slug, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :slug, :description, :title])
    |> validate_required([:name, :slug, :description, :title])
    |> unique_constraint(:slug)
  end
end

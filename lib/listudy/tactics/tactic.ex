defmodule Listudy.Tactics.Tactic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tactics" do
    field :color, :string
    field :description, :string
    field :fen, :string
    field :link, :string
    field :moves, :string
    field :played, :integer
    field :rating, :integer
    field :white, :id
    field :black, :id
    field :event, :id
    field :opening, :id
    field :motif, :id

    timestamps()
  end

  @doc false
  def changeset(tactic, attrs) do
    tactic
    |> cast(attrs, [:fen, :moves, :color, :link, :description, :rating, :played])
    |> validate_required([:fen, :moves, :color, :link, :description, :rating, :played])
  end
end

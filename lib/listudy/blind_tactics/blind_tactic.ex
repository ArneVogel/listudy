defmodule Listudy.BlindTactics.BlindTactic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blind_tactics" do
    field :color, :string
    field :description, :string
    field :pgn, :string
    field :played, :integer, default: 0
    field :ply, :integer

    timestamps()
  end

  @doc false
  def changeset(blind_tactic, attrs) do
    blind_tactic
    |> cast(attrs, [:pgn, :ply, :color, :description, :played])
    |> validate_required([:pgn, :ply, :color, :played])
  end
end

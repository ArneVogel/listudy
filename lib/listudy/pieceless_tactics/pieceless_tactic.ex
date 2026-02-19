defmodule Listudy.PiecelessTactics.PiecelessTactic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "piecelesstactic" do
    field :fen, :string
    field :pieces, :integer
    field :solution, :string

    timestamps()
  end

  @doc false
  def changeset(pieceless_tactic, attrs) do
    pieceless_tactic
    |> cast(attrs, [:fen, :solution, :pieces])
    |> validate_required([:fen, :solution, :pieces])
  end
end

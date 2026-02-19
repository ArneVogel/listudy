defmodule Listudy.ExpertRecommendations.ExpertRecommendation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expert_recommendation" do
    field :source, :string
    field :text, :string
    belongs_to(:book, Listudy.Books.Book)
    belongs_to(:player, Listudy.Players.Player)

    timestamps()
  end

  @doc false
  def changeset(expert_recommendation, attrs) do
    expert_recommendation
    |> cast(attrs, [:text, :source, :player_id, :book_id])
    |> validate_required([:text, :source, :player_id, :book_id])
  end
end

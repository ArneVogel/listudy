defmodule Listudy.ExpertRecommendations.ExpertRecommendation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expert_recommendation" do
    field :source, :string
    field :text, :string
    field :player, :id
    field :book, :id

    timestamps()
  end

  @doc false
  def changeset(expert_recommendation, attrs) do
    expert_recommendation
    |> cast(attrs, [:text, :source, :player, :book])
    |> validate_required([:text, :source, :player, :book])
  end
end

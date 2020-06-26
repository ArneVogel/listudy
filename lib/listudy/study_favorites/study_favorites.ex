defmodule Listudy.StudyFavorites.StudyFavorite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "study_favorites" do
    field :user_id, :id
    field :study_id, :id

    timestamps()
  end

  @doc false
  def changeset(study_favorites, attrs) do
    study_favorites
    |> cast(attrs, [:user_id, :study_id])
    |> validate_required([:user_id, :study_id])
    |> unique_constraint(:favorite_once, name: :favorite_once)
  end
end

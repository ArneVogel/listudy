defmodule Listudy.StudyFavorites do
  @moduledoc """
  The Studies context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.StudyFavorites.StudyFavorite

  def favorite_study(attrs \\ %{}) do
    %StudyFavorite{}
    |> StudyFavorite.changeset(attrs)
    |> Repo.insert()
  end

  def unfavorite_study(user_id, study_id) do
    favorite = List.first(get_favorite(study_id, user_id))
    Repo.delete(favorite)
  end

  def user_favorites_study(user_id, study_id) do
    query =
      from f in StudyFavorite,
        where: f.study_id == ^study_id and f.user_id == ^user_id,
        select: f.id

    result = Repo.all(query)
    length(result) != 0
  end

  def count_favorites(study_id) do
    query =
      from f in StudyFavorite,
        where: f.study_id == ^study_id,
        select: f.id

    Repo.aggregate(query, :count, :id)
  end

  defp get_favorite(study, user) do
    query = from(StudyFavorite, where: [user_id: ^user, study_id: ^study])
    Repo.all(query)
  end
end

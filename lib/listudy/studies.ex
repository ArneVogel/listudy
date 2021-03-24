defmodule Listudy.Studies do
  @moduledoc """
  The Studies context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo
  alias Listudy.Helpers

  alias Listudy.Studies.Study
  alias Listudy.Users.User
  alias Listudy.StudyFavorites.StudyFavorite

  @doc """
  Returns the list of studies.

  ## Examples

      iex> list_studies()
      [%Study{}, ...]

  """
  def list_studies do
    Repo.all(Study)
  end

  @doc """
  Gets a single study.

  Raises `Ecto.NoResultsError` if the Study does not exist.

  ## Examples

      iex> get_study!(123)
      %Study{}

      iex> get_study!(456)
      ** (Ecto.NoResultsError)

  """
  def get_study!(id), do: Repo.get!(Study, id)

  def get_study_by_slug!(slug), do: Repo.get_by(Study, slug: slug)

  @doc """
  Gets a study by the slug id.
  E.g. get study abcdef-this-is-an-awesome-study by abcdef
  """
  def get_study_by_slug_start(id) do
    slug = id <> "%"

    query =
      from s in Study,
        where: like(s.slug, ^slug)

    Repo.one(query)
  end

  def get_study_by_user!(user) do
    query = from(Study, where: [user_id: ^user])
    Repo.all(query)
  end

  def get_public_studies_by_user!(user) do
    query = from(Study, where: [user_id: ^user, private: false])
    Repo.all(query)
  end

  def get_all_public_studies() do
    query =
      from(s in Study,
        join: f in StudyFavorite,
        on: s.id == f.study_id,
        where: s.private == false,
        group_by: s.id,
        select: %{
          :id => s.id,
          :slug => s.slug,
          :favorites => count(f.id),
          :updated_at => s.updated_at
        }
      )

    Repo.all(query)
  end

  def get_opening_studies(opening_id) do
    # TODO optional: change out when enough studies have been uploaded
    # min_favs = Application.get_env(:listudy, :seo)[:study_min_favorites]
    min_favs = 0

    query =
      from(s in Study,
        left_join: f in StudyFavorite,
        on: s.id == f.study_id,
        where: s.private == false and s.opening_id == ^opening_id,
        group_by: s.id,
        limit: 10,
        having: count(f.id) >= ^min_favs,
        select: %{
          :id => s.id,
          :title => s.title,
          :slug => s.slug,
          :description => s.description,
          :favorites => count(f.id)
        }
      )

    Repo.all(query)
  end

  def get_studies_by_favorite!(user) do
    query =
      from s in Study,
        join: f in StudyFavorite,
        on: f.study_id == s.id,
        where: f.user_id == ^user,
        select: s

    Repo.all(query)
  end

  defp by_title(query, word) do
    word = "%" <> word <> "%"

    from c in query,
      where: like(fragment("lower(?)", c.title), fragment("lower(?)", ^word))
  end

  defp not_private(query) do
    from c in query,
      where: not c.private
  end

  defp title_limit(query) do
    from c in query,
      limit: 20
  end

  defp order_by_favorites(query) do
    from c in query,
      join: f in StudyFavorite,
      on: f.study_id == c.id,
      group_by: c.id,
      order_by: [desc: count(f.id)]
  end

  defp order_by_newest(query) do
    from c in query,
      order_by: [desc: c.updated_at]
  end

  def search_by_title(word, "favorites") do
    query =
      Study
      |> by_title(word)
      |> not_private
      |> title_limit
      |> order_by_favorites

    Repo.all(query) |> Repo.preload([:study_favorites, :user])
  end

  def search_by_title(word, "newest") do
    query =
      Study
      |> by_title(word)
      |> not_private
      |> title_limit
      |> order_by_newest

    Repo.all(query) |> Repo.preload([:study_favorites, :user])
  end

  def search_by_title(title) do
    search_by_title(title, "favorites")
  end

  @doc """
  Creates a study.

  ## Examples

      iex> create_study(%{field: value})
      {:ok, %Study{}}

      iex> create_study(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_study(attrs \\ %{}) do
    %Study{}
    |> Study.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a study.

  ## Examples

      iex> update_study(study, %{field: new_value})
      {:ok, %Study{}}

      iex> update_study(study, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_study(%Study{} = study, attrs) do
    study
    |> Study.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a study.

  ## Examples

      iex> delete_study(study)
      {:ok, %Study{}}

      iex> delete_study(study)
      {:error, %Ecto.Changeset{}}

  """
  def delete_study(%Study{} = study) do
    Repo.delete(study)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking study changes.

  ## Examples

      iex> change_study(study)
      %Ecto.Changeset{data: %Study{}}

  """
  def change_study(%Study{} = study, attrs \\ %{}) do
    Study.changeset(study, attrs)
  end

  def study_aggregate() do
    Study
    |> Helpers.count_by_month(:inserted_at)
    |> Repo.all()
  end
end

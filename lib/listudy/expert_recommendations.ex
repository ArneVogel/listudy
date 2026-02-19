defmodule Listudy.ExpertRecommendations do
  @moduledoc """
  The ExpertRecommendations context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.ExpertRecommendations.ExpertRecommendation
  alias Listudy.Players.Player

  @doc """
  Returns the list of expert_recommendation.

  ## Examples

      iex> list_expert_recommendation()
      [%ExpertRecommendation{}, ...]

  """
  def list_expert_recommendation do
    Repo.all(ExpertRecommendation)
  end

  def get_by_book(book) do
    query =
      from r in ExpertRecommendation,
        join: p in Player,
        on: r.player_id == p.id,
        where: r.book_id == ^book,
        select: {r, p}

    Repo.all(query)
  end

  @doc """
  Gets a single expert_recommendation.

  Raises `Ecto.NoResultsError` if the Expert recommendation does not exist.

  ## Examples

      iex> get_expert_recommendation!(123)
      %ExpertRecommendation{}

      iex> get_expert_recommendation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expert_recommendation!(id), do: Repo.get!(ExpertRecommendation, id)

  @doc """
  Creates a expert_recommendation.

  ## Examples

      iex> create_expert_recommendation(%{field: value})
      {:ok, %ExpertRecommendation{}}

      iex> create_expert_recommendation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expert_recommendation(attrs \\ %{}) do
    %ExpertRecommendation{}
    |> ExpertRecommendation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a expert_recommendation.

  ## Examples

      iex> update_expert_recommendation(expert_recommendation, %{field: new_value})
      {:ok, %ExpertRecommendation{}}

      iex> update_expert_recommendation(expert_recommendation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expert_recommendation(%ExpertRecommendation{} = expert_recommendation, attrs) do
    expert_recommendation
    |> ExpertRecommendation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a expert_recommendation.

  ## Examples

      iex> delete_expert_recommendation(expert_recommendation)
      {:ok, %ExpertRecommendation{}}

      iex> delete_expert_recommendation(expert_recommendation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expert_recommendation(%ExpertRecommendation{} = expert_recommendation) do
    Repo.delete(expert_recommendation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expert_recommendation changes.

  ## Examples

      iex> change_expert_recommendation(expert_recommendation)
      %Ecto.Changeset{data: %ExpertRecommendation{}}

  """
  def change_expert_recommendation(%ExpertRecommendation{} = expert_recommendation, attrs \\ %{}) do
    ExpertRecommendation.changeset(expert_recommendation, attrs)
  end
end

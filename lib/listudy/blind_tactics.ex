defmodule Listudy.BlindTactics do
  @moduledoc """
  The BlindTactics context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.BlindTactics.BlindTactic

  @doc """
  Returns the list of blind_tactics.

  ## Examples

      iex> list_blind_tactics()
      [%BlindTactic{}, ...]

  """
  def list_blind_tactics do
    Repo.all(BlindTactic)
  end

  @doc """
  Gets a single blind_tactic.

  Raises `Ecto.NoResultsError` if the Blind tactic does not exist.

  ## Examples

      iex> get_blind_tactic!(123)
      %BlindTactic{}

      iex> get_blind_tactic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_blind_tactic!(id), do: Repo.get!(BlindTactic, id)

  def get_random_tactic() do
    get_random_tactic(-1)
  end

  # get a random tactic, excluding the id
  def get_random_tactic(id) do
    query =
      from t in BlindTactic,
      where: t.id != ^id,
      order_by: fragment("RANDOM()"),
      limit: 1
    Repo.one(query)
  end

  @doc """
  Creates a blind_tactic.

  ## Examples

      iex> create_blind_tactic(%{field: value})
      {:ok, %BlindTactic{}}

      iex> create_blind_tactic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_blind_tactic(attrs \\ %{}) do
    %BlindTactic{}
    |> BlindTactic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a blind_tactic.

  ## Examples

      iex> update_blind_tactic(blind_tactic, %{field: new_value})
      {:ok, %BlindTactic{}}

      iex> update_blind_tactic(blind_tactic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_blind_tactic(%BlindTactic{} = blind_tactic, attrs) do
    blind_tactic
    |> BlindTactic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a blind_tactic.

  ## Examples

      iex> delete_blind_tactic(blind_tactic)
      {:ok, %BlindTactic{}}

      iex> delete_blind_tactic(blind_tactic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_blind_tactic(%BlindTactic{} = blind_tactic) do
    Repo.delete(blind_tactic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking blind_tactic changes.

  ## Examples

      iex> change_blind_tactic(blind_tactic)
      %Ecto.Changeset{data: %BlindTactic{}}

  """
  def change_blind_tactic(%BlindTactic{} = blind_tactic, attrs \\ %{}) do
    BlindTactic.changeset(blind_tactic, attrs)
  end
end

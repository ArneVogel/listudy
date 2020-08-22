defmodule Listudy.Tactics do
  @moduledoc """
  The Tactics context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.Tactics.Tactic

  @doc """
  Returns the list of tactics.

  ## Examples

      iex> list_tactics()
      [%Tactic{}, ...]

  """
  def list_tactics do
    Repo.all(Tactic)
  end

  @doc """
  Gets a single tactic.

  Raises `Ecto.NoResultsError` if the Tactic does not exist.

  ## Examples

      iex> get_tactic!(123)
      %Tactic{}

      iex> get_tactic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tactic!(id), do: Repo.get!(Tactic, id)
  def get_tactic(id), do: Repo.get(Tactic, id)

  def get_random_tactic() do
    get_random_tactic(-1)
  end

  # get a random tactic, excluding the id
  def get_random_tactic(id) do
    query =
      from t in Tactic,
      where: t.id != ^id,
      order_by: fragment("RANDOM()"),
      limit: 1

    Repo.all(query) |> List.first
  end


  @doc """
  Creates a tactic.

  ## Examples

      iex> create_tactic(%{field: value})
      {:ok, %Tactic{}}

      iex> create_tactic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tactic(attrs \\ %{}) do
    %Tactic{}
    |> Tactic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tactic.

  ## Examples

      iex> update_tactic(tactic, %{field: new_value})
      {:ok, %Tactic{}}

      iex> update_tactic(tactic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tactic(%Tactic{} = tactic, attrs) do
    tactic
    |> Tactic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tactic.

  ## Examples

      iex> delete_tactic(tactic)
      {:ok, %Tactic{}}

      iex> delete_tactic(tactic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tactic(%Tactic{} = tactic) do
    Repo.delete(tactic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tactic changes.

  ## Examples

      iex> change_tactic(tactic)
      %Ecto.Changeset{data: %Tactic{}}

  """
  def change_tactic(%Tactic{} = tactic, attrs \\ %{}) do
    Tactic.changeset(tactic, attrs)
  end
end

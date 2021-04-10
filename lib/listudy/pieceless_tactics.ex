defmodule Listudy.PiecelessTactics do
  @moduledoc """
  The PiecelessTactics context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.PiecelessTactics.PiecelessTactic

  @doc """
  Returns the list of piecelesstactic.

  ## Examples

      iex> list_piecelesstactic()
      [%PiecelessTactic{}, ...]

  """
  def list_piecelesstactic do
    Repo.all(PiecelessTactic)
  end

  @doc """
  Gets a single pieceless_tactic.

  Raises `Ecto.NoResultsError` if the Pieceless tactic does not exist.

  ## Examples

      iex> get_pieceless_tactic!(123)
      %PiecelessTactic{}

      iex> get_pieceless_tactic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pieceless_tactic!(id), do: Repo.get!(PiecelessTactic, id)

  def get_random_tactic() do
    get_random_tactic(-1)
  end

  # get a random tactic, excluding the id
  def get_random_tactic(id) do
    query =
      from t in PiecelessTactic,
        where: t.id != ^id,
        order_by: fragment("RANDOM()"),
        limit: 1

    Repo.one(query)
  end

  @doc """
  Creates a pieceless_tactic.

  ## Examples

      iex> create_pieceless_tactic(%{field: value})
      {:ok, %PiecelessTactic{}}

      iex> create_pieceless_tactic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pieceless_tactic(attrs \\ %{}) do
    %PiecelessTactic{}
    |> PiecelessTactic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pieceless_tactic.

  ## Examples

      iex> update_pieceless_tactic(pieceless_tactic, %{field: new_value})
      {:ok, %PiecelessTactic{}}

      iex> update_pieceless_tactic(pieceless_tactic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pieceless_tactic(%PiecelessTactic{} = pieceless_tactic, attrs) do
    pieceless_tactic
    |> PiecelessTactic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pieceless_tactic.

  ## Examples

      iex> delete_pieceless_tactic(pieceless_tactic)
      {:ok, %PiecelessTactic{}}

      iex> delete_pieceless_tactic(pieceless_tactic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pieceless_tactic(%PiecelessTactic{} = pieceless_tactic) do
    Repo.delete(pieceless_tactic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pieceless_tactic changes.

  ## Examples

      iex> change_pieceless_tactic(pieceless_tactic)
      %Ecto.Changeset{data: %PiecelessTactic{}}

  """
  def change_pieceless_tactic(%PiecelessTactic{} = pieceless_tactic, attrs \\ %{}) do
    PiecelessTactic.changeset(pieceless_tactic, attrs)
  end
end

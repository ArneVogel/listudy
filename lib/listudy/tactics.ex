defmodule Listudy.Tactics do
  @moduledoc """
  The Tactics context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo
  alias Listudy.Openings
  alias Listudy.Events
  alias Listudy.Motifs
  alias Listudy.Players

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

  def get_random_tactic("event", slug) do
    event = Listudy.Events.get_by_slug!(slug)
    get_random_event_tactic(-1, event.id)
  end

  def get_random_tactic("player", slug) do
    player = Listudy.Players.get_by_slug!(slug)
    get_random_player_tactic(-1, player.id)
  end

  def get_random_tactic("motif", slug) do
    motif = Listudy.Motifs.get_by_slug!(slug)
    get_random_motif_tactic(-1, motif.id)
  end

  def get_random_tactic("opening", slug) do
    opening = Listudy.Openings.get_by_slug!(slug)
    get_random_opening_tactic(-1, opening.id)
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

  def get_random_event_tactic(id, event) do
    query =
      from t in Tactic,
      where: t.id != ^id and t.event == ^event,
      order_by: fragment("RANDOM()"),
      limit: 1
    Repo.all(query) |> List.first
  end

  def get_random_opening_tactic(id, opening) do
    query =
      from t in Tactic,
      where: t.id != ^id and t.opening == ^opening,
      order_by: fragment("RANDOM()"),
      limit: 1
    Repo.all(query) |> List.first
  end

  def get_random_player_tactic(id, player) do
    query =
      from t in Tactic,
      where: t.id != ^id and (t.white == ^player or t.black == ^player),
      order_by: fragment("RANDOM()"),
      limit: 1
    Repo.all(query) |> List.first
  end


  def get_random_motif_tactic(id, motif) do
    query =
      from t in Tactic,
      where: t.id != ^id and t.motif == ^motif,
      order_by: fragment("RANDOM()"),
      limit: 1
    Repo.all(query) |> List.first
  end

  def increase_played(id) do
    from(t in Tactic, update: [inc: [played: 1]], where: t.id == ^id)
    |> Repo.update_all([])
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

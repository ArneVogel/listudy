defmodule Listudy.Motifs do
  @moduledoc """
  The Motifs context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.Motifs.Motif

  @doc """
  Returns the list of motifs.

  ## Examples

      iex> list_motifs()
      [%Motif{}, ...]

  """
  def list_motifs do
    Repo.all(Motif)
  end

  @doc """
  Gets a single motif.

  Raises `Ecto.NoResultsError` if the Motif does not exist.

  ## Examples

      iex> get_motif!(123)
      %Motif{}

      iex> get_motif!(456)
      ** (Ecto.NoResultsError)

  """
  def get_motif!(id), do: Repo.get!(Motif, id)

  def get_by_slug!(slug), do: Repo.get_by(Motif, slug: slug)

  def search_by_title(word) do
    word = "%" <> word <> "%"
    query = from c in Motif, 
      where: like(fragment("lower(?)",c.name), fragment("lower(?)",^word)),
      limit: 20,
      order_by: [desc: c.updated_at]
    Repo.all(query)
  end

  @doc """
  Creates a motif.

  ## Examples

      iex> create_motif(%{field: value})
      {:ok, %Motif{}}

      iex> create_motif(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_motif(attrs \\ %{}) do
    %Motif{}
    |> Motif.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a motif.

  ## Examples

      iex> update_motif(motif, %{field: new_value})
      {:ok, %Motif{}}

      iex> update_motif(motif, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_motif(%Motif{} = motif, attrs) do
    motif
    |> Motif.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a motif.

  ## Examples

      iex> delete_motif(motif)
      {:ok, %Motif{}}

      iex> delete_motif(motif)
      {:error, %Ecto.Changeset{}}

  """
  def delete_motif(%Motif{} = motif) do
    Repo.delete(motif)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking motif changes.

  ## Examples

      iex> change_motif(motif)
      %Ecto.Changeset{data: %Motif{}}

  """
  def change_motif(%Motif{} = motif, attrs \\ %{}) do
    Motif.changeset(motif, attrs)
  end
end

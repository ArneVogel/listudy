defmodule Listudy.Openings do
  @moduledoc """
  The Openings context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.Openings.Opening

  @doc """
  Returns the list of openings.

  ## Examples

      iex> list_openings()
      [%Opening{}, ...]

  """
  def list_openings do
    Repo.all(Opening)
  end

  @doc """
  Gets a single opening.

  Raises `Ecto.NoResultsError` if the Opening does not exist.

  ## Examples

      iex> get_opening!(123)
      %Opening{}

      iex> get_opening!(456)
      ** (Ecto.NoResultsError)

  """
  def get_opening!(id), do: Repo.get!(Opening, id)

  def get_by_slug!(slug), do: Repo.get_by(Opening, slug: slug)

  def search_by_title(word) do
    word = "%" <> word <> "%"

    query =
      from c in Opening,
        where: like(fragment("lower(?)", c.name), fragment("lower(?)", ^word)),
        limit: 20,
        order_by: [desc: c.updated_at]

    Repo.all(query)
  end

  @doc """
  Creates a opening.

  ## Examples

      iex> create_opening(%{field: value})
      {:ok, %Opening{}}

      iex> create_opening(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_opening(attrs \\ %{}) do
    %Opening{}
    |> Opening.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a opening.

  ## Examples

      iex> update_opening(opening, %{field: new_value})
      {:ok, %Opening{}}

      iex> update_opening(opening, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_opening(%Opening{} = opening, attrs) do
    opening
    |> Opening.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a opening.

  ## Examples

      iex> delete_opening(opening)
      {:ok, %Opening{}}

      iex> delete_opening(opening)
      {:error, %Ecto.Changeset{}}

  """
  def delete_opening(%Opening{} = opening) do
    Repo.delete(opening)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking opening changes.

  ## Examples

      iex> change_opening(opening)
      %Ecto.Changeset{data: %Opening{}}

  """
  def change_opening(%Opening{} = opening, attrs \\ %{}) do
    Opening.changeset(opening, attrs)
  end
end

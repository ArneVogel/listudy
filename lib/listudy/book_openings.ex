defmodule Listudy.BookOpenings do
  @moduledoc """
  The BookOpenings context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.BookOpenings.BookOpening
  alias Listudy.Openings.Opening

  @doc """
  Returns the list of book_opening.

  ## Examples

      iex> list_book_opening()
      [%BookOpening{}, ...]

  """
  def list_book_opening do
    Repo.all(BookOpening)
  end

  def get_by_book(book_id) do
    query =
      from b in BookOpening,
        join: o in Opening,
        on: b.opening_id == o.id,
        where: b.book_id == ^book_id,
        select: o

    Repo.all(query)
  end

  @doc """
  Gets a single book_opening.

  Raises `Ecto.NoResultsError` if the Book opening does not exist.

  ## Examples

      iex> get_book_opening!(123)
      %BookOpening{}

      iex> get_book_opening!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book_opening!(id), do: Repo.get!(BookOpening, id)

  @doc """
  Creates a book_opening.

  ## Examples

      iex> create_book_opening(%{field: value})
      {:ok, %BookOpening{}}

      iex> create_book_opening(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book_opening(attrs \\ %{}) do
    %BookOpening{}
    |> BookOpening.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book_opening.

  ## Examples

      iex> update_book_opening(book_opening, %{field: new_value})
      {:ok, %BookOpening{}}

      iex> update_book_opening(book_opening, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book_opening(%BookOpening{} = book_opening, attrs) do
    book_opening
    |> BookOpening.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book_opening.

  ## Examples

      iex> delete_book_opening(book_opening)
      {:ok, %BookOpening{}}

      iex> delete_book_opening(book_opening)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book_opening(%BookOpening{} = book_opening) do
    Repo.delete(book_opening)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book_opening changes.

  ## Examples

      iex> change_book_opening(book_opening)
      %Ecto.Changeset{data: %BookOpening{}}

  """
  def change_book_opening(%BookOpening{} = book_opening, attrs \\ %{}) do
    BookOpening.changeset(book_opening, attrs)
  end
end

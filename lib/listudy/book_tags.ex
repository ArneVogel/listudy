defmodule Listudy.BookTags do
  @moduledoc """
  The BookTags context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.BookTags.BookTag

  @doc """
  Returns the list of book_tag.

  ## Examples

      iex> list_book_tag()
      [%BookTag{}, ...]

  """
  def list_book_tag do
    Repo.all(BookTag)
  end

  @doc """
  Gets a single book_tag.

  Raises `Ecto.NoResultsError` if the Book tag does not exist.

  ## Examples

      iex> get_book_tag!(123)
      %BookTag{}

      iex> get_book_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book_tag!(id), do: Repo.get!(BookTag, id)

  @doc """
  Creates a book_tag.

  ## Examples

      iex> create_book_tag(%{field: value})
      {:ok, %BookTag{}}

      iex> create_book_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book_tag(attrs \\ %{}) do
    %BookTag{}
    |> BookTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book_tag.

  ## Examples

      iex> update_book_tag(book_tag, %{field: new_value})
      {:ok, %BookTag{}}

      iex> update_book_tag(book_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book_tag(%BookTag{} = book_tag, attrs) do
    book_tag
    |> BookTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book_tag.

  ## Examples

      iex> delete_book_tag(book_tag)
      {:ok, %BookTag{}}

      iex> delete_book_tag(book_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book_tag(%BookTag{} = book_tag) do
    Repo.delete(book_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book_tag changes.

  ## Examples

      iex> change_book_tag(book_tag)
      %Ecto.Changeset{data: %BookTag{}}

  """
  def change_book_tag(%BookTag{} = book_tag, attrs \\ %{}) do
    BookTag.changeset(book_tag, attrs)
  end
end

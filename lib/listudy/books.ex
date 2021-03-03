defmodule Listudy.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.Books.Book
  alias Listudy.BookTags.BookTag

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    Repo.all(Book)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id)

  def get_book_by_slug!(slug), do: Repo.get_by(Book, slug: slug) |> Repo.preload(:author)

  def get_books_by_tag(tag_id) do
    query =
      from b in Book,
        join: t in BookTag,
        on: b.id == t.book_id,
        left_join: r in Listudy.ExpertRecommendations.ExpertRecommendation,
        on: b.id == r.book_id,
        where: t.id == ^tag_id,
        select: b,
        order_by: [desc: count(r.id)]

    Repo.all(query)
  end

  def recommended_books() do
    query =
      from b in Book,
        left_join: r in Listudy.ExpertRecommendations.ExpertRecommendation,
        on: b.id == r.book_id,
        limit: 20,
        group_by: b.id,
        order_by: [desc: count(r.id)]

    Repo.all(query) |> Repo.preload([:author, expert_recommendations: :player])
  end

  def search_by_title(word) do
    word = "%" <> word <> "%"

    query =
      from b in Book,
        join: a in Listudy.Authors.Author,
        on: a.id == b.author_id,
        where:
          like(fragment("lower(?)", b.title), fragment("lower(?)", ^word)) or
            like(fragment("lower(?)", a.name), fragment("lower(?)", ^word)),
        limit: 20,
        order_by: [desc: b.updated_at]

    Repo.all(query) |> Repo.preload(:author)
  end

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end
end

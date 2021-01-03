defmodule ListudyWeb.BookOpeningController do
  use ListudyWeb, :controller

  alias Listudy.BookOpenings
  alias Listudy.Books
  alias Listudy.Openings
  alias Listudy.BookOpenings.BookOpening

  def index(conn, _params) do
    book_opening = BookOpenings.list_book_opening()
    render(conn, "index.html", book_opening: book_opening)
  end

  def new(conn, _params) do
    books = Books.list_books()
    openings = Openings.list_openings()
    changeset = BookOpenings.change_book_opening(%BookOpening{})
    render(conn, "new.html", changeset: changeset, books: books, openings: openings)
  end

  def create(conn, %{"book_opening" => book_opening_params}) do
    case BookOpenings.create_book_opening(book_opening_params) do
      {:ok, book_opening} ->
        conn
        |> put_flash(:info, "Book opening created successfully.")
        |> redirect(to: Routes.book_opening_path(conn, :show, book_opening))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    book_opening = BookOpenings.get_book_opening!(id)
    render(conn, "show.html", book_opening: book_opening)
  end

  def edit(conn, %{"id" => id}) do
    book_opening = BookOpenings.get_book_opening!(id)
    openings = Openings.list_openings()
    books = Books.list_books()
    changeset = BookOpenings.change_book_opening(book_opening)

    render(conn, "edit.html",
      book_opening: book_opening,
      changeset: changeset,
      books: books,
      openings: openings
    )
  end

  def update(conn, %{"id" => id, "book_opening" => book_opening_params}) do
    book_opening = BookOpenings.get_book_opening!(id)

    case BookOpenings.update_book_opening(book_opening, book_opening_params) do
      {:ok, book_opening} ->
        conn
        |> put_flash(:info, "Book opening updated successfully.")
        |> redirect(to: Routes.book_opening_path(conn, :show, book_opening))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", book_opening: book_opening, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book_opening = BookOpenings.get_book_opening!(id)
    {:ok, _book_opening} = BookOpenings.delete_book_opening(book_opening)

    conn
    |> put_flash(:info, "Book opening deleted successfully.")
    |> redirect(to: Routes.book_opening_path(conn, :index))
  end
end

defmodule ListudyWeb.BookTagController do
  use ListudyWeb, :controller

  alias Listudy.Books
  alias Listudy.Tags
  alias Listudy.BookTags
  alias Listudy.BookTags.BookTag

  def index(conn, _params) do
    book_tag = BookTags.list_book_tag()
    render(conn, "index.html", book_tag: book_tag)
  end

  def new(conn, _params) do
    changeset = BookTags.change_book_tag(%BookTag{})
    books = Books.list_books()
    tags = Tags.list_tags()
    render(conn, "new.html", changeset: changeset, books: books, tags: tags)
  end

  def create(conn, %{"book_tag" => book_tag_params}) do
    case BookTags.create_book_tag(book_tag_params) do
      {:ok, book_tag} ->
        conn
        |> put_flash(:info, "Book tag created successfully.")
        |> redirect(to: Routes.book_tag_path(conn, :show, book_tag))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    book_tag = BookTags.get_book_tag!(id)
    render(conn, "show.html", book_tag: book_tag)
  end

  def edit(conn, %{"id" => id}) do
    book_tag = BookTags.get_book_tag!(id)
    books = Books.list_books()
    tags = Tags.list_tags()
    changeset = BookTags.change_book_tag(book_tag)
    render(conn, "edit.html", book_tag: book_tag, changeset: changeset, books: books, tags: tags)
  end

  def update(conn, %{"id" => id, "book_tag" => book_tag_params}) do
    book_tag = BookTags.get_book_tag!(id)

    case BookTags.update_book_tag(book_tag, book_tag_params) do
      {:ok, book_tag} ->
        conn
        |> put_flash(:info, "Book tag updated successfully.")
        |> redirect(to: Routes.book_tag_path(conn, :show, book_tag))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", book_tag: book_tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book_tag = BookTags.get_book_tag!(id)
    {:ok, _book_tag} = BookTags.delete_book_tag(book_tag)

    conn
    |> put_flash(:info, "Book tag deleted successfully.")
    |> redirect(to: Routes.book_tag_path(conn, :index))
  end
end

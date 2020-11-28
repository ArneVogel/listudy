defmodule ListudyWeb.BookController do
  use ListudyWeb, :controller

  alias Listudy.Books
  alias Listudy.Tags
  alias Listudy.Authors
  alias Listudy.Books.Book

  def index(conn, _params) do
    books = Books.list_books()
    render(conn, "index.html", books: books)
  end

  def new(conn, _params) do
    authors = Authors.list_authors()
    changeset = Books.change_book(%Book{})
    render(conn, "new.html", changeset: changeset, authors: authors)
  end

  def create(conn, %{"book" => book_params}) do
    safe_cover(book_params)
    case Books.create_book(book_params) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: Routes.book_path(conn, :show, book))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    render(conn, "show.html", book: book)
  end

  def show(conn, %{"slug" => slug}) do
    book = Books.get_book_by_slug!(slug)
    author = Authors.get_author!(book.author)
    tags = Tags.get_by_book(book.id)
    render(conn, "public.html", book: book, author: author, tags: tags, noindex: true)
  end

  def edit(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    authors = Authors.list_authors()
    changeset = Books.change_book(book)
    render(conn, "edit.html", book: book, changeset: changeset, authors: authors)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Books.get_book!(id)

    safe_cover(book_params)
    case Books.update_book(book, book_params) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: Routes.book_path(conn, :show, book))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", book: book, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    {:ok, _book} = Books.delete_book(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: Routes.book_path(conn, :index))
  end

  defp get_path(file) do
    path = "priv/static/book_cover/"
    File.mkdir(path)
    path <> file
  end

  defp safe_cover(%{"cover" => cover, "slug" => slug}) do
    file = cover.path
    name = file_name(slug)
    IO.puts(file)
    IO.puts(slug)
    IO.puts(name)
    IO.puts(get_path(name))
    File.cp(file, get_path(name))
    File.rm(file)
  end


  defp file_name(slug) do
    slug <> ".jpg"
  end

end

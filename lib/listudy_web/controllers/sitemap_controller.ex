defmodule ListudyWeb.SitemapController do
  use ListudyWeb, :controller

  alias Listudy.Studies
  alias Listudy.Content
  alias Listudy.Books
  alias Listudy.Authors
  alias Listudy.Tags

  def index(conn, _params) do
    studies = Studies.get_all_public_studies()
    posts = Content.public_posts()
    openings = Listudy.Openings.list_openings()

    conn
    |> put_resp_content_type("text/xml")
    |> render("index.xml", studies: studies, posts: posts, openings: openings)
  end

  def books(conn, _params) do
    books = Books.list_books()
    authors = Authors.list_authors()
    tags = Tags.list_tags()

    conn
    |> put_resp_content_type("text/xml")
    |> render("books.xml", books: books, tags: tags, authors: authors)
  end

end

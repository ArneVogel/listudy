defmodule ListudyWeb.SitemapController do
  use ListudyWeb, :controller

  alias Listudy.Studies
  alias Listudy.Content

  def index(conn, _params) do
    studies = Studies.get_all_public_studies()
    posts = Content.public_posts()

    conn
    |> put_resp_content_type("text/xml")
    |> render("index.xml", studies: studies, posts: posts)
  end
end

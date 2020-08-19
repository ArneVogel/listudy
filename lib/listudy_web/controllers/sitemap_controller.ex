defmodule ListudyWeb.SitemapController do
  use ListudyWeb, :controller  

  alias Listudy.Studies

  def index(conn, _params) do
    studies = Studies.get_all_public_studies()

    conn
    |> put_resp_content_type("text/xml")
    |> render("index.xml", studies: studies)
  end
end

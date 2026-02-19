defmodule ListudyWeb.SitemapControllerTest do
  use ListudyWeb.ConnCase

  test "GET /en/sitemap.xml", %{conn: conn} do
    conn = get(conn, "/en/sitemap.xml")
    assert response(conn, 200) =~ "<loc>https://listudy.org/en</loc>"
  end

  test "GET /de/sitemap.xml", %{conn: conn} do
    conn = get(conn, "/de/sitemap.xml")
    assert response(conn, 200) =~ "https://listudy.org/de"
  end
end

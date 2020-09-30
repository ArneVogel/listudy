defmodule ListudyWeb.WebmasterController do
  use ListudyWeb, :controller

  @pages ["custom-tactics"]

  def index(conn, _) do
    render(conn, "index.html")
  end

  def show(conn, %{"page" => page}) do
    renderer(conn, @pages, page)
  end

  defp renderer(conn, pages, page) do
    case Enum.member?(pages, page) do
      true ->
        render(conn, page <> ".html")

      false ->
        conn
        |> put_flash(:info, gettext("This page does not exist"))
        |> redirect(to: Routes.page_path(conn, :index, conn.assigns.locale))
    end
  end
end

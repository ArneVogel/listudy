defmodule ListudyWeb.PageController do
  use ListudyWeb, :controller
  alias Listudy.Content
  alias Listudy.Content.Post

  @languages ["en", "de"]
  @pages ["privacy", "terms-of-service", "imprint", "copyright"]
  @features ["blind-tactics"]

  def index(conn, %{"locale" => locale}) do
    case locale in @languages do
      true ->
        posts = Content.list_published_posts(5)
        tactic = ListudyWeb.TacticController.daily_tactic()
        render(conn, "index.html", posts: posts, tactic: tactic)
      _ ->
        conn
        |> put_flash(:info, (gettext "This page does not exist"))
        |> redirect(to: Routes.page_path(conn, :index, conn.assigns.locale))
      end
  end

  def domain(conn, _params) do
    redirect(conn, to: "/" <> conn.assigns.locale ) 
  end

  def show(conn, %{"page" => page}) do
    renderer(conn, @pages, page)
  end

  def features(conn, %{"page" => page}) do
    renderer(conn, @features, page)
  end

  defp renderer(conn, pages, page) do
    case Enum.member?(pages, page) do
      true ->
        render(conn, page <> ".html")
      false ->
        conn
        |> put_flash(:info, (gettext "This page does not exist"))
        |> redirect(to: Routes.page_path(conn, :index, conn.assigns.locale))
    end
  end


  defp get_locale(conn) do
    case get_session(conn, :locale) do
      nil -> "en"
      result -> result
    end
  end

end

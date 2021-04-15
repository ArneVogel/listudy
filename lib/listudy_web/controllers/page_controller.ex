defmodule ListudyWeb.PageController do
  use ListudyWeb, :controller
  alias Listudy.Content

  @languages Application.get_env(:listudy, :languages)[:translations]
  @pages [
    "privacy",
    "terms-of-service",
    "imprint",
    "copyright",
    "achievements",
    "icons",
    "thanks",
    "changelog"
  ]
  @features ["blind-tactics", "dogestudy", "pieceless-tactics"]

  def index(conn, %{"locale" => locale}) do
    case locale in @languages do
      true ->
        posts = Content.list_published_posts(5)
        tactic = ListudyWeb.TacticController.daily_tactic()
        render(conn, "index.html", posts: posts, tactic: tactic)

      _ ->
        conn
        |> put_flash(:info, gettext("This page does not exist"))
        |> redirect(to: Routes.page_path(conn, :index, conn.assigns.locale))
    end
  end

  def domain(conn, _params) do
    redirect(conn, to: "/" <> conn.assigns.locale)
  end

  def show(conn, %{"page" => page}) do
    renderer(conn, @pages, page)
  end

  def features(conn, %{"page" => page}) do
    renderer(conn, @features, page)
  end

  def play_stockfish(conn, _params) do
    render(conn, "play_stockfish.html")
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

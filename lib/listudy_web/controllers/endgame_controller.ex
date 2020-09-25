defmodule ListudyWeb.EndgameController do
  use ListudyWeb, :controller

  defp endgames do
    %{"basic" => basic()}
  end

  def index(conn, _params) do
    render(conn, "index.html", endgame: endgames())
  end

  def chapter(conn, %{"chapter" => chapter}) do
    render(conn, "chapter.html", chapter: endgames()[chapter], slug: chapter)
  end

  def game(conn, %{"chapter" => chapter_slug, "subchapter" => subchapter_slug, "game" => game}) do
    {game_id, _} = Integer.parse(game)
    index = game_id - 1
    chapter = endgames()[chapter_slug]
    subchapter = chapter[:endgames][String.to_atom(subchapter_slug)]
    game_list = subchapter[:games]
    game = Enum.at(game_list, index)
    next = next(game_list, game_id)

    render(conn, "game.html",
      game: game,
      next: next,
      chapter: chapter,
      chapter_slug: chapter_slug,
      subchapter: subchapter,
      subchapter_slug: subchapter_slug,
      index: game_id,
      noindex: true
    )
  end

  defp next(game_list, index) when length(game_list) == index do
    "back"
  end

  defp next(game_list, index) when length(game_list) > index do
    index + 1
  end

  defp basic() do
    %{
      name: gettext("Checkmating"),
      description: gettext("Learn the basic checkmating techniques."),
      body:
        gettext(
          "This chapter has endgames for checkmating with queen, rook, bishop + knight and bishop + bishop."
        ),
      endgames: [
        queen: %{
          name: gettext("Queen"),
          games: [
            ["3k4/7Q/3K4/8/8/8/8/8 w - - 0 1", "w"],
            ["3k4/8/3K4/8/8/8/7Q/8 w - - 0 1", "w"],
            ["3k4/8/8/3K4/8/8/7Q/8 w - - 0 1", "w"],
            ["8/3k4/8/3K4/8/8/7Q/8 w - - 0 1", "w"],
            ["8/8/3k4/8/3K4/4Q3/8/8 w - - 0 1", "w"],
            ["8/8/5k2/8/8/3KQ3/8/8 w - - 0 1", "w"],
            ["8/5K2/3Q4/5k2/8/8/8/8 w - - 0 1", "w"]
          ]
        },
        rook: %{
          name: gettext("Rook"),
          games: [
            ["3k4/7R/3K4/8/8/8/8/8 w - - 0 1", "w"],
            ["1k6/7R/3K4/8/8/8/8/8 w - - 0 1", "w"],
            ["2k5/7R/3K4/8/8/8/8/8 w - - 0 1", "w"],
            ["2k5/8/3K4/8/7R/8/8/8 w - - 0 1", "w"],
            ["8/3k4/8/3K4/8/7R/8/8 w - - 0 1", "w"],
            ["8/2k5/8/3K4/8/7R/8/8 w - - 0 1", "w"],
            ["8/8/8/3k4/8/3K3R/8/8 w - - 0 1", "w"],
            ["8/8/8/5k2/8/3K3R/8/8 w - - 0 1", "w"]
          ]
        },
        "bishop-bishop": %{
          name: gettext("Bishop + Bishop"),
          games: [
            ["k7/3B4/K2B4/8/8/8/8/8 w - - 0 1", "w"],
            ["k7/3B4/KB6/8/8/8/8/8 w - - 0 1", "w"],
            ["1k6/8/KBB5/8/8/8/8/8 w - - 0 1", "w"],
            ["1k6/8/1BB1K3/8/8/8/8/8 w - - 0 1", "w"],
            ["7k/8/6K1/2BB4/8/8/8/8 w - - 0 1", "w"],
            ["5k2/8/1BB3K1/8/8/8/8/8 w - - 0 1", "w"],
            ["4k3/8/1B2K3/3B4/8/8/8/8 w - - 0 1", "w"],
            ["2k5/8/5K2/3BB3/8/8/8/8 w - - 0 1", "w"],
            ["8/4k3/8/3BB3/8/8/4K3/8 w - - 0 1", "w"],
            ["8/8/8/8/3k4/8/8/2B1KB2 w - - 0 1", "w"]
          ]
        },
        "bishop-knight": %{
          name: gettext("Bishop + Knight"),
          games: [
            ["k7/3N4/BK6/8/8/8/8/8 w - - 0 1", "w"],
            ["1k6/1B6/1K3N2/8/8/8/8/8 w - - 0 1", "w"],
            ["8/k7/B7/K2N4/8/8/8/8 w - - 0 1", "w"],
            ["8/1k6/8/1BKN4/8/8/8/8 w - - 0 1", "w"],
            ["8/8/8/1k6/8/1BKN4/8/8 w - - 0 1", "w"],
            ["8/6k1/8/3BK3/4N3/8/8/8 w - - 0 1", "w"],
            ["8/8/8/3k4/8/8/8/3BNK2 w - - 0 1", "w"],
            ["8/8/8/3k4/8/8/8/3NBK2 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end
end

defmodule ListudyWeb.EndgameController do
  use ListudyWeb, :controller

  defp endgames do
    %{
      "basic" => %{
        name: gettext("Basic Checkmating"),
        description: gettext("Learn the basic checkmating techniques."),
        body: gettext("This chapter has endgames for checkmating with queen and rook."),
        endgames: %{
          "q" => %{
            name: gettext("Queen"),
            games: [
              ["8/2k5/8/8/3KQ3/8/8/8 w - - 0 1", "w"],
              ["8/6P1/1k3P2/8/8/1K6/8/8 w - - 0 1", "w"],
              ["8/6P1/1k3P2/8/8/1K6/8/8 w - - 0 1", "p"],
              ["8/3k4/8/2p5/2K5/8/8/8 w - - 0 1", "d"],
              ["8/2k5/8/8/3KQ3/8/8/8 w - - 0 1", "w"]
            ]
          },
          "r" => %{name: gettext("Rook"), games: [["8/2k5/8/8/3KR3/8/8/8 w - - 0 1", "w"]]}
        }
      }
    }
  end

  def index(conn, _params) do
    render(conn, "index.html", endgame: endgames())
  end

  def chapter(conn, %{"chapter" => chapter}) do
    render(conn, "chapter.html", chapter: endgames()[chapter], slug: chapter)
  end

  def game(conn, %{"chapter" => chapter, "subchapter" => subchapter, "game" => game}) do
    {index, _} = Integer.parse(game)
    game_list = endgames()[chapter][:endgames][subchapter][:games]
    game = Enum.at(game_list, index)
    next = next(game_list, index)
    render(conn, "game.html", game: game, next: next, chapter: chapter, subchapter: subchapter, index: index)
  end

  defp next(game_list, index) when length(game_list) == index + 1 do
    "back"
  end

  defp next(game_list, index) when length(game_list) > index do
    index + 1
  end
end

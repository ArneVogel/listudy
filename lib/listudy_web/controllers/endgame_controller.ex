defmodule ListudyWeb.EndgameController do
  use ListudyWeb, :controller

  defp endgames do
    [basic: basic(), "king-and-pawn": king_and_pawn(), "chess-fundamentals": fundamentals()]
  end

  def index(conn, _params) do
    render(conn, "index.html", endgame: endgames())
  end

  def chapter(conn, %{"chapter" => chapter}) do
    render(conn, "chapter.html", chapter: endgames()[String.to_atom(chapter)], slug: chapter)
  end

  def game(conn, %{"chapter" => chapter_slug, "subchapter" => subchapter_slug, "game" => game}) do
    {game_id, _} = Integer.parse(game)
    index = game_id - 1
    chapter = endgames()[String.to_atom(chapter_slug)]
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

  defp fundamentals() do
    %{
      name: gettext("Capablancas Chess Fundamentals"),
      description:
        gettext("Play the endgames from Capablancas renowned book \"Chess Fundamentals\"."),
      body:
        gettext(
          "In these chapters are the endgames from Capablancas chess book \"Chess Fundamentals\". Learn the most important endgame fundamentals such as the opposition, creating a passed pawn and checkmating ideas."
        ),
      endgames: [
        "simples-mates": %{
          name: gettext("Simple Mates"),
          games: [
            ["7k/8/8/8/8/8/8/R6K w - - 0 1", "w"],
            ["8/8/8/4k3/8/8/8/4K2R w - - 0 1", "w"],
            ["7k/8/8/8/8/8/8/2B1KB2 w - - 0 1", "w"],
            ["8/8/8/4k3/8/8/8/4K2Q w - - 0 1", "w"]
          ]
        },
        "pawn-promotion": %{
          name: gettext("Pawn Promotion"),
          games: [
            ["8/8/5k2/8/5K2/8/4P3/8 w - - 0 1", "p"],
            ["8/3kp3/8/4K3/8/8/8/8 w - - 0 1", "d"]
          ]
        },
        "pawn-endings": %{
          name: gettext("Pawn Endings"),
          games: [
            ["5k2/6p1/4K1P1/5P2/8/8/8/8 w - - 0 1", "w"],
            ["8/6p1/3k4/8/3K1PP1/8/8/8 w - - 0 1", "w"],
            ["8/6pp/3k4/8/3K1PPP/8/8/8 w - - 0 1", "w"],
            ["8/p6p/3k4/8/3K4/8/P5PP/8 w - - 0 1", "w"],
            ["8/p5p1/7p/6k1/8/7K/PP5P/8 w - - 0 1", "d"],
            ["8/6kp/8/4K3/8/6P1/7P/8 w - - 0 1", "w"]
          ]
        },
        "passed-pawn": %{
          name: gettext("Obtaining a Passed Pawn"),
          games: [
            ["8/ppp4k/8/PPP5/8/8/7K/8 w - - 0 1", "w"],
            ["8/p5kp/8/1P6/8/1K6/P7/8 w - - 0 1", "w"]
          ]
        },
        "the-opposition": %{
          name: gettext("The Opposition"),
          games: [
            ["8/8/4k3/1p5p/1P2K2P/8/8/8 w - - 0 1", "d"],
            ["4k3/8/8/1p5p/1P5P/8/8/4K3 w - - 0 1", "w"],
            ["8/8/8/4p1p1/8/5P2/6K1/3k4 w - - 0 1", "d"]
          ]
        },
        "values-of-knight-and-bishop": %{
          name: gettext("The Relative Value of Knight and Bishop"),
          games: [
            ["k7/8/1K1NN3/8/8/8/8/8 w - - 0 1", "d"],
            ["k7/8/1K1N4/7p/7N/8/8/8 w - - 0 1", "w"],
            ["8/7p/8/2b3k1/8/8/8/7K w - - 0 1", "d"],
            ["8/8/5Np1/8/8/7p/5K2/7k w - - 0 1", "w"]
          ]
        },
        "queen-against-rook": %{
          name: gettext("Queen against Rook"),
          games: [
            ["1k6/1r6/2K5/Q7/8/8/8/8 w - - 0 1", "w"],
            ["8/k7/2K5/4Q3/8/8/8/1r6 w - - 0 1", "w"],
            ["8/5rk1/8/5Q1K/8/8/8/8 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp king_and_pawn() do
    %{
      name: gettext("King and Pawn Endgames"),
      description: gettext("Win games with only Pawns on the board"),
      body: gettext("This chapter has endgames about the King and Pawn endgame."),
      endgames: [
        "endings-of-games": %{
          name: gettext("Endings of Games"),
          description: gettext("From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["8/3k4/1p1P4/1P1K4/8/8/8/8 w - - 0 1", "w"],
            ["3k4/3p4/8/3P4/3P4/3K4/8/8 w - - 0 1", "w"],
            ["8/6kp/8/7P/7K/8/6P1/8 w - - 0 1", "w"],
            ["4k3/5p2/3K4/4PP2/8/8/8/8 w - - 0 1", "w"],
            ["8/8/3pkp2/8/8/3PK3/5P2/8 w - - 0 1", "w"],
            ["8/2k5/2Pp3p/1P6/8/5K2/8/8 w - - 0 1", "w"],
            ["8/kp6/8/1p6/1P6/5K2/P7/8 w - - 0 1", "w"],
            ["8/2p5/7P/8/2Pk4/3p4/5K2/8 w - - 0 1", "w"],
            ["8/8/8/2p5/2Pp4/3K2Pk/7P/8 w - - 0 1", "w"],
            ["8/3p4/3k4/3p4/3P4/2PKP3/8/8 w - - 0 1", "w"],
            ["8/1p1k4/8/2PK3p/2P5/7P/8/8 w - - 0 1", "w"],
            ["8/8/6k1/8/4p2P/5pP1/5K1P/8 w - - 0 1", "w"],
            ["8/5p2/7p/2pk3P/1p1p2P1/8/3K4/8 w - - 0 1", "w"],
            ["8/3p4/3p4/5p2/2kP1P2/8/4P3/2K5 w - - 0 1", "w"],
            ["8/pp6/8/1PP1k3/6p1/4P1K1/8/8 w - - 0 1", "w"],
            ["k7/2p1pp2/2P3p1/4P1P1/5P2/p7/Kp3P2/8 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end
end

defmodule ListudyWeb.EndgameController do
  use ListudyWeb, :controller

  defp endgames do
    [
      basic: basic(),
      "king-and-pawn": king_and_pawn(),
      "kings-bishops-and-pawns": kings_bishops_and_pawns(),
      "knights-bishops-and-pawns": knights_bishops_and_pawns(),
      "two-minor-pieces-against-one": two_minor_pieces_against_one(),
      "rook-against-pawns": rook_against_pawns(),
      "rook-against-minor-pieces": rook_against_minor_pieces(),
      "minor-pieces-against-rook": minor_pieces_against_rook(),
      "queen-against-pawns": queen_against_pawns(),
      "queens-and-pawns": queens_and_pawns(),
      "queen-against-rook": queen_against_rook(),
      "queen-against-minor-pieces": queen_against_minor_pieces()
    ]
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
      name: dgettext("endgame", "Checkmating"),
      description: dgettext("endgame", "Learn the basic checkmating techniques."),
      body:
        dgettext(
          "endgame",
          "This chapter has endgames for checkmating with queen, rook, bishop + knight and bishop + bishop."
        ),
      endgames: [
        queen: %{
          name: dgettext("endgame", "Queen"),
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
          name: dgettext("endgame", "Rook"),
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
          name: dgettext("endgame", "Bishop + Bishop"),
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
          name: dgettext("endgame", "Bishop + Knight"),
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

  defp king_and_pawn() do
    %{
      name: dgettext("endgame", "King and Pawn Endgames"),
      description: dgettext("endgame", "Win games with only Pawns on the board"),
      body:
        dgettext(
          "endgame",
          "This chapter has endgames about the King and Pawn endgame. Many of the examples are taken from Capablancas \"Chess Fundamentals\"."
        ),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
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
        },
        "pawn-promotion": %{
          name: dgettext("endgame", "Pawn Promotion"),
          games: [
            ["8/8/5k2/8/5K2/8/4P3/8 w - - 0 1", "p"],
            ["8/3kp3/8/4K3/8/8/8/8 w - - 0 1", "d"],
            ["8/7p/5K2/8/6P1/8/6kP/8 w - - 0 1", "p"]
          ]
        },
        "pawn-endings": %{
          name: dgettext("endgame", "Pawn Endings"),
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
          name: dgettext("endgame", "Obtaining a Passed Pawn"),
          games: [
            ["8/ppp4k/8/PPP5/8/8/7K/8 w - - 0 1", "w"],
            ["8/p5kp/8/1P6/8/1K6/P7/8 w - - 0 1", "w"]
          ]
        },
        "the-opposition": %{
          name: dgettext("endgame", "The Opposition"),
          games: [
            ["8/8/4k3/1p5p/1P2K2P/8/8/8 w - - 0 1", "d"],
            ["4k3/8/8/1p5p/1P5P/8/8/4K3 w - - 0 1", "w"],
            ["8/8/8/4p1p1/8/5P2/6K1/3k4 w - - 0 1", "d"]
          ]
        }
      ]
    }
  end

  defp kings_bishops_and_pawns() do
    %{
      name: dgettext("endgame", "Bishops and Pawns"),
      description: dgettext("endgame", "Endgames with only Bishops and Pawns on the board."),
      body: dgettext("endgame", "This chapter has endgames about Pawn and Bishop endings."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["8/8/2b5/2P5/1k1K1P2/8/8/8 w - - 0 1", "w"],
            ["1k1b4/1P1P4/K1P5/8/8/8/8/8 w - - 0 1", "w"],
            ["3B4/4P3/8/8/8/3K4/p7/1k6 w - - 0 1", "w"],
            ["8/8/8/5KB1/p7/P4k2/8/8 w - - 0 1", "w"],
            ["8/8/1k6/1p1K4/1p3B2/8/P7/8 w - - 0 1", "w"],
            ["8/8/P7/2pK4/2P2p2/7p/5kBp/8 w - - 0 1", "w"],
            ["8/4pK1k/8/3PPP2/8/b7/8/8 w - - 0 1", "w"],
            ["6bk/6p1/4p1PP/4P2K/8/8/8/8 w - - 0 1", "w"],
            ["8/8/2pB4/pp6/P7/P7/4K3/7k w - - 0 1", "w"],
            ["8/4p3/3Bpp2/8/3kPP2/8/8/4K3 w - - 0 1", "w"],
            ["7K/5k1P/P7/1P1b1pP1/8/8/8/8 w - - 0 1", "w"],
            ["1k1K4/1p6/pP2B3/P4p2/6p1/8/8/8 w - - 0 1", "w"],
            ["1BK5/1P6/k7/8/3b4/8/8/8 w - - 0 1", "w"],
            ["8/1B2B3/8/8/5K1p/7k/8/8 w - - 0 1", "w"],
            ["4k3/2B5/5K2/8/2B5/8/5p2/6b1 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp knights_bishops_and_pawns() do
    %{
      name: dgettext("endgame", "Knights, Bishops and Pawns"),
      description: dgettext("endgame", "Endgames with Knights, Bishops and Pawns."),
      body: dgettext("endgame", "This chapter has endgames about Knight and Bishop endings."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["k7/2K5/8/nPN5/8/8/8/8 w - - 0 1", "w"],
            ["8/2k2b2/4p1p1/2K1P1P1/2N5/8/8/8 w - - 0 1", "w"],
            ["8/5k2/3K1Ppp/5pP1/B2n4/8/8/8 w - - 0 1", "w"],
            ["6bk/3p4/3Np2K/4Pp2/5P2/8/8/8 w - - 0 1", "w"],
            ["8/8/8/8/3p4/1K1N4/8/1k4N1 w - - 0 1", "w"],
            ["8/8/8/8/8/6K1/3N1p2/5N1k w - - 0 1", "w"],
            ["8/8/8/8/4p3/4N1K1/5p2/5N1k w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp two_minor_pieces_against_one() do
    %{
      name: dgettext("endgame", "Two Minor Pieces against one Minor Piece"),
      description:
        dgettext("endgame", "Two minor pieces gainst one minor piece, with and without pawns."),
      body: dgettext("endgame", "Two against one."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["8/5k2/5n2/5K2/8/5B2/8/4B3 w - - 0 1", "w"],
            ["7k/4b3/6K1/7N/8/8/8/2B5 w - - 0 1", "w"],
            ["8/8/8/8/3B4/2N5/1pK5/k1b5 w - - 0 1", "w"],
            ["1B6/8/1N6/8/8/kp6/p7/n2K4 w - - 0 1", "w"],
            ["8/8/8/6N1/4p1B1/6p1/7p/4K1kn w - - 0 1", "w"],
            ["4b2k/4Np2/5P1K/8/8/8/3B4/8 w - - 0 1", "w"],
            ["4B3/8/6N1/8/5p2/6pk/7p/4K2n w - - 0 1", "d"],
            ["8/kn2K3/8/p1p5/P1P4n/8/1PB5/8 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp rook_against_pawns() do
    %{
      name: dgettext("endgame", "Rook against Pawns"),
      description: dgettext("endgame", "Rook against Pawn endgames."),
      body: dgettext("endgame", "Train rook against pawn endgames."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["8/8/8/8/k1K5/2p5/1p5R/8 w - - 0 1", "w"],
            ["8/8/5K2/7k/8/p7/1p6/1R6 w - - 0 1", "d"],
            ["8/5R2/8/8/8/2kp4/3p1K2/8 w - - 0 1", "d"],
            ["2R5/7k/5K2/8/p7/8/1p6/8 w - - 0 1", "d"],
            ["8/1k6/7R/1Kp5/1p6/8/p7/8 w - - 0 1", "d"],
            ["8/8/Kp2r3/8/PP6/8/6k1/8 w - - 0 1", "d"]
          ]
        }
      ]
    }
  end

  defp rook_against_minor_pieces() do
    %{
      name: dgettext("endgame", "Rook against minor Pieces"),
      description: dgettext("endgame", "Rook against minor pieces endgames."),
      body:
        dgettext("endgame", "Rook and pawn against bishop or knight, with and without pawns."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["7k/4R3/5K2/8/8/8/7P/1b6 w - - 0 1", "w"],
            ["5k2/6R1/5K2/8/8/5b2/8/8 w - - 0 1", "w"],
            ["7K/5k2/7P/3b4/8/8/1R6/8 w - - 0 1", "w"],
            ["8/8/8/8/8/4K1b1/3Rp3/4k3 w - - 0 1", "w"],
            ["5k2/7n/8/5K2/8/8/8/6R1 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp minor_pieces_against_rook() do
    %{
      name: dgettext("endgame", "Minor pirces against Rook"),
      description: dgettext("endgame", "Minor pieces against Rook endgames."),
      body: dgettext("endgame", "Bishops and/or knights against rook, with and without pawns."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["6k1/8/r2BK2P/6N1/8/8/8/8 w - - 0 1", "w"],
            ["7k/r7/5NKB/8/8/8/7P/8 w - - 0 1", "w"],
            ["7k/8/r4NKP/8/7B/8/8/8 w - - 0 1", "w"],
            ["7k/8/7P/r1BK2N1/8/8/8/8 w - - 0 1", "w"],
            ["6k1/1r6/7P/5B1K/3B4/8/8/8 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp queen_against_pawns() do
    %{
      name: dgettext("endgame", "Queen against Pawns"),
      description: dgettext("endgame", "Queen against pawn endgames."),
      body: dgettext("endgame", "Queen against pawn endgames."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["8/7Q/6p1/5k2/8/8/8/K7 w - - 0 1", "w"],
            ["1K3Q2/8/8/8/8/8/1p3p2/k7 w - - 0 1", "w"],
            ["3K1Q2/8/8/8/8/8/3p3p/3k4 w - - 0 1", "w"],
            ["7Q/8/8/8/8/3k4/p6p/3K4 w - - 0 1", "d"],
            ["8/8/8/8/8/4k3/3pp2Q/1K6 w - - 0 1", "w"],
            ["8/8/8/1Q6/7p/7p/p6K/k7 w - - 0 1", "w"],
            ["8/8/8/8/8/1Q3pp1/p5p1/k5K1 w - - 0 1", "w"],
            ["8/8/8/8/2p5/Qp6/pK4p1/6k1 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp queens_and_pawns() do
    %{
      name: dgettext("endgame", "Queens and Pawns"),
      description: dgettext("endgame", "Queens and pawn endgames."),
      body: dgettext("endgame", "Train endgames with queens and pawns on the board."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["8/3KP1q1/8/8/8/4Q3/k7/8 w - - 0 1", "w"],
            ["1k6/3q4/3P4/3K4/5Q2/8/8/8 w - - 0 1", "w"],
            ["K7/1P6/5Q2/1k6/8/8/8/7q w - - 0 1", "w"],
            ["3Q4/8/8/8/8/3K4/1P6/q2k4 w - - 0 1", "w"],
            ["1q6/1P3Q2/4K3/8/1k6/8/8/8 w - - 0 1", "w"],
            ["4K3/5P2/6q1/8/8/5Q2/k7/8 w - - 0 1", "w"],
            ["6K1/5PQ1/4q3/8/1k6/8/8/8 w - - 0 1", "w"],
            ["7q/4K1k1/7p/6P1/8/8/8/7Q w - - 0 1", "w"],
            ["6k1/5q2/3Pp2K/8/8/8/8/7Q w - - 0 1", "w"],
            ["k7/8/2K5/pp3q2/8/8/8/2Q5 w - - 0 1", "w"],
            ["5qk1/7p/8/6K1/8/7P/6P1/Q7 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp queen_against_rook() do
    %{
      name: dgettext("endgame", "Queen against Rook"),
      description: dgettext("endgame", "Queen against Rook"),
      body: dgettext("endgame", "Train queen and rook endgames."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["7k/6r1/5K2/8/8/8/8/4Q3 w - - 0 1", "w"],
            ["K2k4/8/1q6/8/8/8/8/R7 w - - 0 1", "d"],
            ["4k3/8/4r3/2Q5/4p3/4K3/8/8 w - - 0 1", "w"],
            ["k7/pr6/8/2KQ4/8/8/8/8 w - - 0 1", "w"],
            ["8/3k4/3p4/4r3/3K1Q2/8/8/8 w - - 0 1", "w"],
            ["8/4r3/5k2/5p2/4pQ2/4K3/8/8 w - - 0 1", "w"],
            ["K7/3p1Q2/kp6/p7/1r6/8/8/8 w - - 0 1", "w"],
            ["8/8/8/5k2/5p1p/2Q1pr2/8/6K1 w - - 0 1", "w"]
          ]
        },
        euclid: %{
          name: dgettext("endgame", "King and Queen against King and Rook"),
          description:
            dgettext(
              "endgame",
              "From the book \"Analysis of the  Chess Ending King and Queen against King and Rook\"."
            ),
          games: [
            ["3k4/3r4/8/2K1Q3/8/8/8/8 w - - 0 1", "w"],
            ["8/3k4/8/6r1/3KQ3/8/8/8 w - - 0 1", "w"],
            ["2k5/r7/3K4/1Q6/8/8/8/8 w - - 0 1", "w"],
            ["8/3Q4/kr6/2K5/8/8/8/8 w - - 0 1", "w"],
            ["2k5/5Q2/3K4/8/8/8/8/2r5 w - - 0 1", "w"],
            ["3k4/2r5/4K3/1Q6/8/8/8/8 w - - 0 1", "w"],
            ["1k6/1r6/2K5/Q7/8/8/8/8 w - - 0 1", "w"],
            ["2k5/2r5/3K4/1Q6/8/8/8/8 w - - 0 1", "w"],
            ["2k5/6r1/3K4/1Q6/8/8/8/8 w - - 0 1", "w"],
            ["8/1k6/8/1K6/8/8/2Q5/4r3 w - - 0 1", "w"]
          ]
        },
        "chess-fundamentals": %{
          name: dgettext("endgame", "Chess Fundamentals"),
          description: dgettext("endgame", "From the Capablancas \"Chess Fundamentals\"."),
          games: [
            ["1k6/1r6/2K5/Q7/8/8/8/8 w - - 0 1", "w"],
            ["8/k7/2K5/4Q3/8/8/8/1r6 w - - 0 1", "w"],
            ["8/5rk1/8/5Q1K/8/8/8/8 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end

  defp queen_against_minor_pieces() do
    %{
      name: dgettext("endgame", "Queen against Minor Pieces"),
      description: dgettext("endgame", "Queen against minor pieces."),
      body: dgettext("endgame", "Train queen and minor piece endgames."),
      endgames: [
        "endings-of-games": %{
          name: dgettext("endgame", "Endings of Games"),
          description:
            dgettext("endgame", "From the book \"Chess Studies, Or, Endings of Games\"."),
          games: [
            ["8/5Q2/8/8/8/6kp/p5p1/1b4K1 w - - 0 1", "w"],
            ["K7/8/2n3k1/n7/8/Q7/8/8 w - - 0 1", "d"],
            ["4k3/3r1b2/2Q2K2/8/8/8/8/8 w - - 0 1", "w"],
            ["k1b5/7r/1PK5/1Q6/8/8/8/8 w - - 0 1", "w"],
            ["8/8/4Q3/8/8/4K1k1/8/6nr w - - 0 1", "w"],
            ["1q5k/5Rp1/6KP/4N3/8/8/8/8 w - - 0 1", "d"],
            ["1k2r3/4r1Q1/1KP5/8/8/8/8/8 w - - 0 1", "w"],
            ["4q3/8/8/8/3N1N2/3K2R1/7k/8 w - - 0 1", "w"],
            ["8/2k5/1q6/8/3R4/5B2/4RK2/8 w - - 0 1", "w"],
            ["8/3B4/8/3q4/2N1kp2/2P2p1N/2K2P2/8 w - - 0 1", "w"]
          ]
        }
      ]
    }
  end
end

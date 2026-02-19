defmodule Listudy.Seeds do
  def call do
    alias Listudy.Users.User
    alias Listudy.Tactics.Tactic
    alias Listudy.BlindTactics.BlindTactic
    alias Listudy.Motifs.Motif
    alias Listudy.Openings.Opening
    alias Listudy.Events.Event
    alias Listudy.Players.Player
    alias Listudy.Authors.Author
    alias Listudy.Books.Book
    alias Listudy.Content.Post
    alias Listudy.ExpertRecommendations.ExpertRecommendation

    user = %User{
      username: "Arne",
      role: "admin",
      email: "arne@listudy.org",
      # temppass
      password_hash:
        "$pbkdf2-sha512$100000$j7PasHrv6LMbGdCqpYVrTA==$A3+0bz2XFCmQx7OMssNE1nmp+KRUKusLy3ZDV09yut6QCfZwXewEmyXY9RRJH2Z09LVH84uiRRGk/ioaeBKoSQ=="
    }

    regular = %User{
      username: "Regular",
      role: "user",
      email: "regular@listudy.org",
      # temppass
      password_hash:
        "$pbkdf2-sha512$100000$j7PasHrv6LMbGdCqpYVrTA==$A3+0bz2XFCmQx7OMssNE1nmp+KRUKusLy3ZDV09yut6QCfZwXewEmyXY9RRJH2Z09LVH84uiRRGk/ioaeBKoSQ=="
    }

    motif = %Motif{
      name: "Uncategorized",
      description: "Uncategorized",
      slug: "uncategorized"
    }

    event = %Event{
      name: "Uncategorized",
      description: "Uncategorized",
      slug: "uncategorized"
    }

    player = %Player{
      name: "Uncategorized",
      description: "Uncategorized",
      slug: "uncategorized"
    }

    opening = %Opening{
      name: "Uncategorized",
      description: "Uncategorized",
      slug: "uncategorized"
    }

    tactic = %Tactic{
      color: "black",
      description: "",
      fen: "r3k3/pppb4/6N1/3Pp3/N3n2b/8/PP1P2PP/R1B2K1R b q - 0 17",
      link: "",
      moves: "Bb5+ d3 Bxd3+ Kg1 Bf2#",
      last_move: "h8g6",
      played: 0,
      rating: 1500,
      white: 1,
      black: 1,
      event: 1,
      opening: 1,
      motif: 1
    }

    blind_tactic = %BlindTactic{
      color: "white",
      description: "",
      pgn:
        "1. e4 Nf6 2. e5 Nd5 3. Nf3 d6 4. Bc4 Nb6 5. Bxf7+ Kxf7 6. Ng5+ Kg8 7. e6 h6 8. Qf3 Qe8 9. Qf7+ Qxf7 10. exf7# ",
      played: 0,
      ply: 16
    }

    author = %Author{
      name: "J. R. R. Tolkien",
      slug: "tolkien",
      description: "The creator of Lord of the Rings."
    }

    book = %Book{
      title: "The Hobbit",
      slug: "the-hobbit",
      author_id: 1,
      year: 1937,
      isbn: "some-number",
      amazon_id: "some-id",
      summary: "The story of a Hobbits Holiday",
      text: "Some text at the bottom."
    }

    recommendation = %ExpertRecommendation{
      book_id: 1,
      player_id: 1,
      text: "A great book!",
      source: "I read it."
    }

    post = %Post{
      body: "Example body",
      published: true,
      slug: "example-post",
      title: "Example Post",
      script: "",
      author_id: 1
    }

    Listudy.Repo.insert!(user)
    Listudy.Repo.insert!(regular)
    Listudy.Repo.insert!(event)
    Listudy.Repo.insert!(motif)
    Listudy.Repo.insert!(player)
    Listudy.Repo.insert!(opening)
    Listudy.Repo.insert!(tactic)
    Listudy.Repo.insert!(blind_tactic)
    Listudy.Repo.insert!(author)
    Listudy.Repo.insert!(book)
    Listudy.Repo.insert!(post)
    Listudy.Repo.insert!(recommendation)
  end
end

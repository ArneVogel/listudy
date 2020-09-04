defmodule Listudy.Seeds do
  def call do
    alias Listudy.Users.User
    alias Listudy.Tactics.Tactic
    alias Listudy.Motifs.Motif
    alias Listudy.Openings.Opening
    alias Listudy.Events.Event
    alias Listudy.Players.Player

    user = %User{
      username: "Arne",
      role: "admin",
      email: "arne@listudy.org",
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
      opening: 1,
      event: 1,
      opening: 1,
      motif: 1
    }

    Listudy.Repo.insert!(user)
    Listudy.Repo.insert!(event)
    Listudy.Repo.insert!(motif)
    Listudy.Repo.insert!(player)
    Listudy.Repo.insert!(opening)
    Listudy.Repo.insert!(tactic)
  end
end

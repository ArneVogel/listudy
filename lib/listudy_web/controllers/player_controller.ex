defmodule ListudyWeb.PlayerController do
  use ListudyWeb, :controller

  alias Listudy.Tactics
  alias Listudy.Players
  alias Listudy.Books
  alias Listudy.Players.Player

  def index(conn, _params) do
    players = Players.list_players()
    render(conn, "index.html", players: players)
  end

  def new(conn, _params) do
    changeset = Players.change_player(%Player{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"player" => player_params}) do
    case Players.create_player(player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player created successfully.")
        |> redirect(to: Routes.player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    render(conn, "show.html", player: player)
  end

  # For public usage
  def show(conn, %{"player" => id}) do
    player = Players.get_by_slug!(id)
    tactics_amount = Tactics.player_count(player.id)
    tactic = Tactics.get_random_tactic("player", player.slug)

    render(conn, "public.html",
      player: player,
      tactics_amount: tactics_amount,
      tactic: tactic,
      noindex: true
    )
  end

  def book_recommendation(conn, %{"slug" => id}) do
    player = Players.get_by_slug!(id)
    books = Books.recommended_by(player.id)

    noindex = length(books) >= 1

    render(conn, "book_recommendations.html",
      player: player,
      books: books,
      noindex: noindex
    )
  end

  def edit(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    changeset = Players.change_player(player)
    render(conn, "edit.html", player: player, changeset: changeset)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = Players.get_player!(id)

    case Players.update_player(player, player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player updated successfully.")
        |> redirect(to: Routes.player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", player: player, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    {:ok, _player} = Players.delete_player(player)

    conn
    |> put_flash(:info, "Player deleted successfully.")
    |> redirect(to: Routes.player_path(conn, :index))
  end
end

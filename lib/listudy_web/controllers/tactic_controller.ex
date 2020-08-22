defmodule ListudyWeb.TacticController do
  use ListudyWeb, :controller

  alias Listudy.Motifs
  alias Listudy.Players
  alias Listudy.Events
  alias Listudy.Openings
  alias Listudy.Tactics
  alias Listudy.Tactics.Tactic

  def index(conn, _params) do
    tactics = Tactics.list_tactics()
    render(conn, "index.html", tactics: tactics)
  end

  def random(conn, _params) do
    tactic = Tactics.get_random_tactic() 
    conn
    |> redirect(to: Routes.tactics_path(conn, ListudyWeb.TacticsLive, conn.private.plug_session["locale"], tactic))
  end

  def new(conn, _params) do
    changeset = Tactics.change_tactic(%Tactic{})
    motifs = Motifs.list_motifs()
    openings = Openings.list_openings()
    events = Events.list_events()
    players = Players.list_players()
    render(conn, "new.html", changeset: changeset, motifs: motifs, openings: openings, events: events, players: players)
  end

  def create(conn, %{"tactic" => tactic_params}) do
    case Tactics.create_tactic(tactic_params) do
      {:ok, tactic} ->
        conn
        |> put_flash(:info, "Tactic created successfully.")
        |> redirect(to: Routes.tactic_path(conn, :show, tactic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tactic = Tactics.get_tactic!(id)
    motifs = Motifs.list_motifs()
    openings = Openings.list_openings()
    events = Events.list_events()
    players = Players.list_players()
    render(conn, "show.html", tactic: tactic, motifs: motifs, openings: openings, events: events, players: players)
  end

  def edit(conn, %{"id" => id}) do
    tactic = Tactics.get_tactic!(id)
    motifs = Motifs.list_motifs()
    openings = Openings.list_openings()
    events = Events.list_events()
    players = Players.list_players()
    changeset = Tactics.change_tactic(tactic)
    render(conn, "edit.html", tactic: tactic, changeset: changeset, motifs: motifs, openings: openings, events: events, players: players)
  end

  def update(conn, %{"id" => id, "tactic" => tactic_params}) do
    tactic = Tactics.get_tactic!(id)
    motifs = Motifs.list_motifs()
    openings = Openings.list_openings()
    events = Events.list_events()
    players = Players.list_players()

    case Tactics.update_tactic(tactic, tactic_params) do
      {:ok, tactic} ->
        conn
        |> put_flash(:info, "Tactic updated successfully.")
        |> redirect(to: Routes.tactic_path(conn, :show, tactic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tactic: tactic, changeset: changeset, motifs: motifs, openings: openings, events: events, players: players)
    end
  end

  def join("app:" <> token, _payload, socket) do
    {:ok, assign(socket, :channel, "app:#{token}")}
  end

  def delete(conn, %{"id" => id}) do
    tactic = Tactics.get_tactic!(id)
    {:ok, _tactic} = Tactics.delete_tactic(tactic)

    conn
    |> put_flash(:info, "Tactic deleted successfully.")
    |> redirect(to: Routes.tactic_path(conn, :index))
  end
end

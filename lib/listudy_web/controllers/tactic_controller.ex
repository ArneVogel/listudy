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

  def daily(conn, _params) do
    tactic = daily_tactic()
    render(conn, "daily.html", tactic: tactic)
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

  def random(conn, params) do
    tactic = get_tactic(params)
    url = get_url(conn, params, tactic)
    conn
    |> redirect(to: url)
  end

  defp get_tactic(%{"opening" => slug}) do
    Tactics.get_random_tactic("opening", slug) 
  end

  defp get_tactic(%{"event" => slug}) do
    Tactics.get_random_tactic("event", slug) 
  end

  defp get_tactic(%{"motif" => slug}) do
    Tactics.get_random_tactic("motif", slug) 
  end

  defp get_tactic(%{"player" => slug}) do
    Tactics.get_random_tactic("player", slug) 
  end

  defp get_tactic(_params) do
    Tactics.get_random_tactic() 
  end

  defp get_url(conn, %{"opening" => slug}, tactic) do
    Routes.opening_tactics_path(conn, ListudyWeb.TacticsLive, conn.private.plug_session["locale"], slug, tactic)
  end

  defp get_url(conn, %{"event" => slug}, tactic) do
    Routes.event_tactics_path(conn, ListudyWeb.TacticsLive, conn.private.plug_session["locale"], slug, tactic)
  end

  defp get_url(conn, %{"motif" => slug}, tactic) do
    Routes.motif_tactics_path(conn, ListudyWeb.TacticsLive, conn.private.plug_session["locale"], slug, tactic)
  end

  defp get_url(conn, %{"player" => slug}, tactic) do
    Routes.player_tactics_path(conn, ListudyWeb.TacticsLive, conn.private.plug_session["locale"], slug, tactic)
  end

  defp get_url(conn, _params, tactic) do
    Routes.tactics_path(conn, ListudyWeb.TacticsLive, conn.private.plug_session["locale"], tactic)
  end

  def daily_tactic() do
    id = daily_id()
    Tactics.get_tactic!(id)
  end

  defp daily_id() do
    total = Tactics.tactics_count()
    {{year, month, day}, _} = :calendar.universal_time
    rem((year*1001+month*12345+day*54321), total) + 1
  end
end

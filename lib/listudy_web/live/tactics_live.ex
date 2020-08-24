defmodule ListudyWeb.TacticsLive do
  use Phoenix.LiveView

  alias Listudy.Tactics
  alias Listudy.Openings
  alias Listudy.Events
  alias Listudy.Players
  alias Listudy.Motifs
  import ListudyWeb.Gettext
  alias ListudyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(ListudyWeb.LiveView ,"tactics.html", assigns)
  end

  def mount(%{"locale" => locale, "id" => id} = params, session, socket) do
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    tactic = Tactics.get_tactic!(id)
    socket = add_extra(params, socket)
    canonical = Routes.tactics_path(socket, ListudyWeb.TacticsLive, "en", tactic)
    {:ok, assign(socket, locale: locale, tactic: tactic, canonical: canonical)}
  end

  def handle_event("next", _value, socket) do
    Tactics.increase_played(socket.assigns.tactic.id)
    tactic = get_next_tactic(socket)
    url = get_next_url(socket, tactic)
    {:noreply, push_redirect(socket, to: url, replace: true)}
  end

  defp add_extra(%{"motif" => slug}, socket) do
    motif = Motifs.get_by_slug!(slug)
    assign(socket, :motif, motif)
  end

  defp add_extra(%{"opening" => slug}, socket) do
    opening = Openings.get_opening_by_slug!(slug)
    assign(socket, :opening, opening)
  end

  defp add_extra(%{"event" => slug}, socket) do
    event = Events.get_by_slug!(slug)
    assign(socket, :event, event)
  end

  defp add_extra(%{"player" => slug}, socket) do
    player = Players.get_by_slug!(slug)
    assign(socket, :player, player)
  end

  defp add_extra(_params, socket) do
    socket
  end

  defp get_next_tactic(%{:assigns => %{:opening => opening}} = socket) do
    Tactics.get_random_opening_tactic(socket.assigns.tactic.id, opening.id)
  end

  defp get_next_tactic(%{:assigns => %{:motif => motif}} = socket) do
    Tactics.get_random_motif_tactic(socket.assigns.tactic.id, motif.id)
  end

  defp get_next_tactic(%{:assigns => %{:event => event}} = socket) do
    Tactics.get_random_event_tactic(socket.assigns.tactic.id, event.id)
  end

  defp get_next_tactic(%{:assigns => %{:player => player}} = socket) do
    Tactics.get_random_player_tactic(socket.assigns.tactic.id, player.id)
  end

  defp get_next_tactic(socket) do
    Tactics.get_random_tactic(socket.assigns.tactic.id)
  end

  defp get_next_url(%{:assigns => %{:opening => opening}} = socket, tactic) do
    Routes.opening_tactics_path(socket, ListudyWeb.TacticsLive, socket.assigns.locale, opening.slug, tactic)
  end

  defp get_next_url(%{:assigns => %{:motif => motif}} = socket, tactic) do
    Routes.motif_tactics_path(socket, ListudyWeb.TacticsLive, socket.assigns.locale, motif.slug, tactic)
  end

  defp get_next_url(%{:assigns => %{:event => event}} = socket, tactic) do
    Routes.event_tactics_path(socket, ListudyWeb.TacticsLive, socket.assigns.locale, event.slug, tactic)
  end

  defp get_next_url(%{:assigns => %{:player => player}} = socket, tactic) do
    Routes.player_tactics_path(socket, ListudyWeb.TacticsLive, socket.assigns.locale, player.slug, tactic)
  end

  defp get_next_url(socket, tactic) do
    Routes.tactics_path(socket, ListudyWeb.TacticsLive, socket.assigns.locale, tactic)
  end
end

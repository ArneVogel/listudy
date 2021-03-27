defmodule ListudyWeb.BlindTacticsLive do
  require Logger
  use Phoenix.LiveView

  alias Listudy.BlindTactics
  alias ListudyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(ListudyWeb.LiveView, "blind_tactics.html", assigns)
  end

  def mount(%{"locale" => locale, "id" => id}, _session, socket) do
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    tactic = BlindTactics.get_blind_tactic!(id)
    socket = assign(socket, :noindex, true)
    {:ok, assign(socket, locale: locale, tactic: tactic)}
  end

  def handle_event("next", _value, socket) do
    BlindTactics.increase_played(socket.assigns.tactic.id)
    tactic = get_next_tactic(socket)
    url = get_next_url(socket, tactic)
    {:noreply, push_redirect(socket, to: url, replace: true, tactic: tactic)}
  end

  def handle_event(event, _, socket) do
    Logger.error "Unhandled event in blind tactics live: #{event}"
    {:noreply, socket}
  end


  defp get_next_tactic(socket) do
    BlindTactics.get_random_tactic(socket.assigns.tactic.id)
  end

  defp get_next_url(socket, tactic) do
    Routes.blind_tactics_path(socket, ListudyWeb.BlindTacticsLive, socket.assigns.locale, tactic)
  end
end

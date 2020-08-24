defmodule ListudyWeb.TacticsLive do
  use Phoenix.LiveView

  alias Listudy.Tactics
  alias Listudy.Openings
  import ListudyWeb.Gettext
  alias ListudyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(ListudyWeb.LiveView ,"tactics.html", assigns)
  end

  def mount(%{"locale" => locale, "id" => id, "opening" => opening_slug} = params, session, socket) do
    opening = Openings.get_opening_by_slug!(opening_slug)
    socket = assign(socket, :opening, opening)
    params = Map.delete(params, "opening")
    mount(params, session, socket)
  end

  def mount(%{"locale" => locale, "id" => id}, session, socket) do
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    tactic = Tactics.get_tactic!(id)
    canonical = Routes.tactics_path(socket, ListudyWeb.TacticsLive, "en", tactic)
    {:ok, assign(socket, locale: locale, tactic: tactic, canonical: canonical)}
  end

  def handle_event("next", _value, socket) do
    Tactics.increase_played(socket.assigns.tactic.id)
    tactic = get_next_tactic(socket)
    url = get_next_url(socket, tactic)
    {:noreply, push_redirect(socket, to: url, replace: true)}
  end

  defp get_next_tactic(%{:assigns => %{:opening => opening}} = socket) do
    Tactics.get_random_tactic(socket.assigns.tactic.id)
  end

  defp get_next_tactic(socket) do
    Tactics.get_random_tactic(socket.assigns.tactic.id)
  end

  defp get_next_url(%{:assigns => %{:opening => opening}} = socket, tactic) do
    Routes.opening_tactics_path(socket, ListudyWeb.TacticsLive, socket.assigns.locale, socket.assigns.opening.slug, tactic)
  end

  defp get_next_url(socket, tactic) do
    Routes.tactics_path(socket, ListudyWeb.TacticsLive, socket.assigns.locale, tactic)
  end
end

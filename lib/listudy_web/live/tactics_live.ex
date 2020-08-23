defmodule ListudyWeb.TacticsLive do
  use Phoenix.LiveView

  alias Listudy.Tactics
  import ListudyWeb.Gettext
  alias ListudyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(ListudyWeb.LiveView ,"tactics.html", assigns)
  end

  def mount(%{"locale" => locale, "id" => id}, session, socket) do
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    tactic = Tactics.get_tactic!(id)
    {:ok, assign(socket, locale: locale, tactic: tactic)}
  end

  def handle_event("next", _value, socket) do
    tactic = Tactics.get_random_tactic(socket.assigns.tactic.id)
    Tactics.increase_played(socket.assigns.tactic.id)
    {:noreply, push_redirect(socket, to: Routes.tactics_path(socket, ListudyWeb.TacticsLive, socket.assigns.locale, tactic), replace: true)}
  end

end

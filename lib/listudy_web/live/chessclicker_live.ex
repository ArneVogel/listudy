defmodule ListudyWeb.ChessClickerLive do
  use Phoenix.LiveView

  alias Listudy.Tactics

  def render(assigns) do
    Phoenix.View.render(ListudyWeb.LiveView, "chessclicker.html", assigns)
  end

  def mount(%{"locale" => locale}, _session, socket) do
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    tactic = Tactics.get_random_easy_tactic()
    {:ok, assign(socket, locale: locale, tactic: tactic)}
  end

  def handle_event("next", _value, socket) do
    tactic = Tactics.get_random_easy_tactic()
    {:noreply, assign(socket, tactic: tactic)}
  end
end

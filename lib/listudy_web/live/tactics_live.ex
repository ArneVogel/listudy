defmodule ListudyWeb.TacticsLive do
  use Phoenix.LiveView

  alias Listudy.Tactics
  import ListudyWeb.Gettext

  def render(assigns) do
    Phoenix.View.render(ListudyWeb.LiveView ,"tactics.html", assigns)
  end

  def mount(%{"locale" => locale, "id" => id}, session, socket) do
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    tactic = Tactics.get_tactic!(id)
    {:ok, assign(socket, locale: locale, tactic: tactic)}
  end

end

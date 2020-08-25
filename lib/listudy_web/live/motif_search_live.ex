defmodule ListudyWeb.MotifSearchLive do
  use Phoenix.LiveView

  alias Listudy.Motifs
  import ListudyWeb.Gettext
  alias ListudyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <h1><%= gettext "Motifs" %></h1>
    <form phx-change="suggest" phx-submit="search">
      <input class="big_search" type="text" name="q" value="<%= @query %>" list="matches" placeholder="<%= gettext "Search"%>..." autocomplete="off"/>
      <br>
      <%= for match <- @matches do %>
        <a href="<%= Routes.motif_path(@socket, :show, @locale, match.slug) %>"><%= match.name %></a>
        <a href="<%= Routes.random_motif_tactic_path(@socket, :random, @locale, match.slug) %>">[Tactics]</a>
        <br>
      <% end %>
    </form>
    """
  end

  def mount(%{"locale" => locale}, session, socket) do
    result = Motifs.search_by_title("")
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    {:ok, assign(socket, query: nil, matches: result, locale: locale)}
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    result = Motifs.search_by_title(query)
    {:noreply, assign(socket, matches: result)}
  end
end

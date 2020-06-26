defmodule ListudyWeb.StudySearchLive do
  use Phoenix.LiveView

  alias Listudy.Studies
  import ListudyWeb.Gettext

  def render(assigns) do
    ~L"""
    <h1><%= gettext "Search for studies" %></h1>
    <form phx-change="suggest" phx-submit="search">
      <input class="big_search" type="text" name="q" value="<%= @query %>" list="matches" placeholder="<%= gettext "Search"%>..." autocomplete="off"/>
      <br>
      <%= for match <- @matches do %>
        <a href="/<%=@locale%>/studies/<%=match.slug%>"><%= match.title %></a> 
        <%= gettext "by" %> 
        <a href="/<%=@locale%>/profile/<%=match.username%>"><%= match.username %></a> 
        <p><%= shorten_description(match.description) %></p>

      <% end %>

    </form>
    """
  end

  def mount(%{"locale" => locale}, session, socket) do
    result = Studies.search_by_title("")
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    {:ok, assign(socket, query: nil, matches: result, locale: locale)}
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    result = Studies.search_by_title(query)
    {:noreply, assign(socket, matches: result)}
  end

  defp shorten_description(description) do
    limit = 200
    case String.length(description) do
      n when n < limit ->
        description
      _ ->
        String.slice(description, 0, limit) <> "..."
    end
  end
end

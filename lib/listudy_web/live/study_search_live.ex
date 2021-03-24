defmodule ListudyWeb.StudySearchLive do
  use Phoenix.LiveView

  alias Listudy.Studies
  import ListudyWeb.Gettext

  def render(assigns) do
    ~L"""
    <h1><%= dgettext("study", "Search for studies") %></h1>
    <form phx-change="suggest" phx-submit="search">
      <input class="big_search" type="text" name="q" value="<%= @query %>" list="matches" placeholder="<%= dgettext("study", "Search") %>..." autocomplete="off"/>
      <select name="ordering" id="ordering">
        <option value="favorites" <%= if @ordering == "favorites" do %>selected<%end%>><%= dgettext("study", "Favorites")%></option>
        <option value="newest" <%= if @ordering == "newest" do %>selected<%end%>><%= dgettext("study", "Newest")%></option>
      </select>
      <br>
      <div class="study_search_results">
        <%= for match <- @matches do %>
          <div class="study_search_result">
            <a href="/<%=@locale%>/studies/<%=match.slug%>">
              <h5><%= match.title %></h5>
            </a>
            <span title="# <%= dgettext("study", "favorites")%>"><%= length(match.study_favorites) %> <span class="icon" data-icon="#"></span></span> <%= dgettext("study", "by") %> <%= match.user.username %>
            <p><%= shorten_description(match.description) %></p>
          </div>
          </a>

        <% end %>
      </div>

    </form>
    """
  end

  def mount(%{"locale" => locale}, _session, socket) do
    result = Studies.search_by_title("")
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    {:ok, assign(socket, query: nil, ordering: "favorites", matches: result, locale: locale)}
  end

  def handle_event(_, %{"q" => query, "ordering" => order}, socket) when byte_size(query) <= 100 do
    result = Studies.search_by_title(query, order)
    {:noreply, assign(socket, matches: result, ordering: order, query: query)}
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

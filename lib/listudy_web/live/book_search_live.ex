defmodule ListudyWeb.BookSearchLive do
  use Phoenix.LiveView

  alias Listudy.Books
  import ListudyWeb.Gettext
  alias ListudyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <h1><%= gettext "Chess Book Search" %></h1>
    <form phx-change="suggest" phx-submit="search">
      <input class="big_search" type="text" name="q" value="<%= @query %>" list="matches" placeholder="<%= gettext "Search"%>..." autocomplete="off"/>
      <br>
      <%= for match <- @matches do %>
        <p><a href="<%= Routes.book_path(@socket, :show, @locale, match.slug) %>"><%= match.title %></a>
        <%= gettext("by") %>:
        <a href="<%= Routes.author_path(@socket, :show, @locale, match.author.slug) %>"><%= match.author.name %></a>
        </p>
      <% end %>
    </form>
    """
  end

  def mount(%{"locale" => locale}, _session, socket) do
    result = Books.search_by_title("")
    Gettext.put_locale(ListudyWeb.Gettext, locale)
    socket = assign(socket, noindex: true)
    {:ok, assign(socket, query: nil, matches: result, locale: locale)}
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    result = Books.search_by_title(query)
    {:noreply, assign(socket, matches: result)}
  end
end

defmodule ListudyWeb.PageDescription do
  alias ListudyWeb.StudySearchLive
  import ListudyWeb.Gettext

  def page_description(assigns), do: assigns |> get

  defp get(%{view_module: Elixir.ListudyWeb.TacticView, view_template: "daily.html"}) do
    gettext("Solve the Daily Chess Puzzle! Updated every day from our list of best puzzles.")
  end

  defp get(%{view_module: Elixir.ListudyWeb.PageView, view_template: "play_stockfish.html"}),
    do: gettext("Play against Stockfish Online - Unlimited and for Free")

  defp get(%{view_module: Elixir.ListudyWeb.StudyView, view_template: "show.html", study: study}),
    do: trim(study.description)

  defp get(%{view_module: Elixir.ListudyWeb.PostView, view_template: "show.html", post: post}),
    do: trim(hd(String.split(post.body, "\n")))

  defp get(%{live_module: StudySearchLive}),
    do: gettext("Search for studies to train specific openings")

  defp get(%{view_module: Elixir.ListudyWeb.MotifView, view_template: "public.html", motif: motif}) do
    gettext(
      "Get better at %{name} tactics with our huge library of puzzles taken from real games. Explore our free collection of %{name} tactics.",
      name: motif.name
    )
  end

  defp get(%{view_module: Elixir.ListudyWeb.EventView, view_template: "public.html", event: event}) do
    gettext("Play tactics from the event %{}. Are you better than the professionals?",
      name: event.name
    )
  end

  defp get(%{
         view_module: Elixir.ListudyWeb.PlayerView,
         view_template: "public.html",
         player: player
       }) do
    gettext("Explore our collection of tactics taken from games by %{name}.", name: player.name)
  end

  defp get(%{
         view_module: Elixir.ListudyWeb.OpeningView,
         view_template: "public.html",
         opening: opening
       }) do
    gettext(
      "Get better in the %{name} opening. Study the opening and learn from traps and tactics collected from real games.",
      name: opening.name
    )
  end

  defp get(%{
         view_module: Elixir.ListudyWeb.EndgameView,
         view_template: "chapter.html",
         chapter: chapter
       }),
       do: chapter.description

  defp get(%{
         view_module: Elixir.ListudyWeb.EndgameView,
         view_template: "index.html"
       }),
       do: gettext("Learn chess endgames interactively playing against Stockfish")

  defp get(%{
         view_module: Elixir.ListudyWeb.BookView,
         view_template: "public.html",
         book: book
       }),
       do: book.summary

  defp get(%{
         view_module: Elixir.ListudyWeb.BookView,
         view_template: "recommended.html"
       }),
       do: "Browse the best chess books in this list of 20 books in the order in which they were ranked by grandmasters."


  defp get(%{
         view_module: Elixir.ListudyWeb.AuthorView,
         view_template: "public.html",
         author: author
       }),
       do: author.description

  defp get(%{
         view_module: Elixir.ListudyWeb.TagView,
         view_template: "public.html",
         tag: tag
       }),
       do: tag.summary


  defp get(_), do: gettext("Improve your chess game on Listudy")

  defp trim(s) do
    if String.length(s) < 160 do
      s
    else
      String.slice(s, 0, 160) <> "..."
    end
  end
end

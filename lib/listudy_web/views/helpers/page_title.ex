defmodule ListudyWeb.PageTitle do
  alias ListudyWeb.{PageView, StudySearchLive, TacticsLive}
  import ListudyWeb.Gettext

  @suffix "Listudy"

  def page_title(assigns), do: assigns |> get |> put_suffix

  defp put_suffix(nil), do: @suffix
  defp put_suffix(title), do: title <> " - " <> @suffix

  defp get(%{view_module: Elixir.ListudyWeb.TacticView, view_template: "daily.html"}),
    do: gettext("Daily Chess Puzzle")

  defp get(%{view_module: PageView, view_template: "blind-tactics.html"}),
    do: gettext("Blind Tactics")

  defp get(%{view_module: PageView, view_template: "play_stockfish.html"}),
    do: gettext("Play against Stockfish Online")

  defp get(%{view_module: PageView, view_template: "achievements.html"}),
    do: gettext("Achievements")

  defp get(%{view_module: PageView}), do: gettext("Improve you chess game with spaced repetition")

  defp get(%{view_module: Elixir.ListudyWeb.StudyView, view_template: "show.html", study: study}),
    do: study.title

  defp get(%{view_module: Elixir.ListudyWeb.PostView, view_template: "show.html", post: post}),
    do: post.title

  defp get(%{live_module: StudySearchLive}), do: gettext("Search Studies")
  defp get(%{live_module: TacticsLive}), do: gettext("Tactics")

  defp get(%{view_module: Elixir.ListudyWeb.MotifView, view_template: "public.html", motif: motif}),
       do: motif.name

  defp get(%{view_module: Elixir.ListudyWeb.EventView, view_template: "public.html", event: event}),
       do: event.name

  defp get(%{
         view_module: Elixir.ListudyWeb.EndgameView,
         view_template: "chapter.html",
         chapter: chapter
       }),
       do: chapter.name

  defp get(%{
         view_module: Elixir.ListudyWeb.EndgameView,
         view_template: "index.html"
       }),
       do: gettext("Endgames")

  defp get(%{
         view_module: Elixir.ListudyWeb.EndgameView,
         view_template: "game.html",
         subchapter: subchapter,
         index: index
       }),
       do: "#{subchapter.name} #{index}"

  defp get(%{
         view_module: Elixir.ListudyWeb.PlayerView,
         view_template: "public.html",
         player: player
       }),
       do: player.name

  defp get(%{
         view_module: Elixir.ListudyWeb.OpeningView,
         view_template: "public.html",
         opening: opening
       }),
       do: opening.name

  defp get(%{
         view_module: Elixir.ListudyWeb.BookView,
         view_template: "public.html",
         book: book
       }),
       do: "#{book.title} by #{book.author.name}"

  defp get(%{
         view_module: Elixir.ListudyWeb.BookView,
         view_template: "recommended.html"
       }),
       do: "The 20 best Chess Books as recommended by Grandmasters"


  defp get(%{
         view_module: Elixir.ListudyWeb.AuthorView,
         view_template: "public.html",
         author: author
       }),
       do: author.name

  defp get(%{
         view_module: Elixir.ListudyWeb.TagView,
         view_template: "public.html",
         tag: tag
       }),
       do: tag.title


  defp get(_), do: nil
end

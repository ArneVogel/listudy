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

  defp get(%{view_module: PageView}), do: gettext("Improve you chess game with spaced repetition")

  defp get(%{view_module: Elixir.ListudyWeb.StudyView, view_template: "show.html", study: study}),
    do: study.title

  defp get(%{view_module: Elixir.ListudyWeb.PostView, view_template: "show.html", post: post}),
    do: post.title

  defp get(%{live_module: StudySearchLive}), do: gettext("Search Studies")
  defp get(%{live_module: TacticsLive, tactic: tactic}), do: gettext("Tactics")

  defp get(%{view_module: Elixir.ListudyWeb.MotifView, view_template: "public.html", motif: motif}),
       do: motif.name

  defp get(%{view_module: Elixir.ListudyWeb.EventView, view_template: "public.html", event: event}),
       do: event.name

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

  defp get(_), do: nil
end

defmodule ListudyWeb.PageTitle do
  alias ListudyWeb.{ PageView, StudySearchLive }
  import ListudyWeb.Gettext

  @suffix "Listudy"

  def page_title(assigns), do: assigns |> get |> put_suffix

  defp put_suffix(nil), do: @suffix
  defp put_suffix(title), do: title <> " - " <> @suffix

  defp get(%{ view_module: PageView}), do: gettext("Homepage")
  defp get(%{ view_module: Elixir.ListudyWeb.StudyView, view_template: "show.html", "study": study}), do: study.title
  defp get(%{ view_module: Elixir.ListudyWeb.PostView, view_template: "show.html", "post": post}), do: post.title
  defp get(%{ live_module: StudySearchLive}), do: gettext("Search Studies")
  defp get(_), do: nil
end

defmodule ListudyWeb.PageDescription do
  alias ListudyWeb.{ PageView, StudySearchLive }
  import ListudyWeb.Gettext

  def page_description(assigns), do: assigns |> get 

  defp get(%{ view_module: Elixir.ListudyWeb.StudyView, view_template: "show.html", "study": study}), do: trim(study.description)
  defp get(%{ view_module: Elixir.ListudyWeb.PostView, view_template: "show.html", "post": post}), do: trim(hd(String.split(post.body, "\n")))
  defp get(%{ live_module: StudySearchLive}), do: gettext("Search for studies to train specific openings")
  defp get(_), do: gettext("Improve your chess game on Listudy")

  defp trim(s) do
    if String.length(s) < 160 do
      s
    else
      String.slice(s, 0, 160) <> "..."
    end
  end
end

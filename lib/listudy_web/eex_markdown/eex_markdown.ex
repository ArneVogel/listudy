defmodule ListudyWeb.EexMarkdown do
  @moduledoc """
  Documentation for EexMarkdown.
  """

  @doc """
  Hello world.
  """
  def as_html(lines, options \\ %Earmark.Options{}) do
    {:ok, html, _} = lines
      |> EEx.eval_string([], functions: [{ListudyWeb.EexMarkdown.Helper, ListudyWeb.EexMarkdown.Helper.__info__(:functions)}])
      |> Earmark.as_html(options)
    html
  end
end

defmodule ListudyWeb.SitemapView do
  use ListudyWeb, :view

  def base_url do
    "https://listudy.org"
  end

  def format_date(date) do
    date
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_date()
    |> to_string()
  end
end

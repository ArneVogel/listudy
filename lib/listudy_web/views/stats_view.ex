defmodule ListudyWeb.StatsView do
  use ListudyWeb, :view

  def month(datetime) do
    year_string = hd(String.split(to_string(datetime), " "))
    [year, month, date] = String.split(year_string, "-")
    year <> "-" <> month
  end
end



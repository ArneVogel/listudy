defmodule ListudyWeb.PostView do
  use ListudyWeb, :view

  def date(datetime) do
    hd(String.split(to_string(datetime), " "))
  end
end

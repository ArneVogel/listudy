defmodule ListudyWeb.LayoutView do
  use ListudyWeb, :view

  def is_halloween(date) do
    {{_, month, day}, {hour, _, _}} = date
    (month == 10 and day in 27..31) or (month == 11 and day == 1 and hour in 0..6)
  end

  def is_halloween do
    is_halloween(:calendar.universal_time())
  end
end

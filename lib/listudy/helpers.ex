defmodule Listudy.Helpers do
  import Ecto.Query, warn: false

  @doc "Count responses per month on `date_field` (atom)"
  def count_by_month(query, date_field) do
      query
      |> group_by([r], (fragment("date_trunc('month', ?)", (field(r, ^date_field)))))
      |> select([r], [(fragment("date_trunc('month', ?)", (field(r, ^date_field)))), count("*")])
  end
end

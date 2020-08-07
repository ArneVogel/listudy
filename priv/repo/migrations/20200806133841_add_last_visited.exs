defmodule Listudy.Repo.Migrations.AddLastVisited do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :last_visited, :utc_datetime
    end
  end
end

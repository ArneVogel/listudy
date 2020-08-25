defmodule Listudy.Repo.Migrations.TacticsAddLastMove do
  use Ecto.Migration

  def change do
    alter table("tactics") do
      add :last_move, :string
    end
  end
end

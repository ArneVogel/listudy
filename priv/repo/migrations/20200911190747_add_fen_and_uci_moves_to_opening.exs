defmodule Listudy.Repo.Migrations.AddFenAndUciMovesToOpening do
  use Ecto.Migration

  def change do
    alter table("openings") do
      add :fen, :string
      add :uci_moves, :string
    end
  end
end

defmodule Listudy.Repo.Migrations.CreateBlindTactics do
  use Ecto.Migration

  def change do
    create table(:blind_tactics) do
      add :pgn, :string
      add :ply, :integer
      add :color, :string
      add :description, :string
      add :played, :integer

      timestamps()
    end

  end
end

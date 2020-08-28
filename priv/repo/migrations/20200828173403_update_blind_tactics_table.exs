defmodule Listudy.Repo.Migrations.UpdateBlindTacticsTable do
  use Ecto.Migration

  def change do
    alter table(:blind_tactics) do
      modify :pgn, :text
    end
  end
end

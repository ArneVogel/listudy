defmodule Listudy.Repo.Migrations.CreatePiecelesstactic do
  use Ecto.Migration

  def change do
    create table(:piecelesstactic) do
      add :fen, :string
      add :solution, :string
      add :pieces, :integer

      timestamps()
    end
  end
end

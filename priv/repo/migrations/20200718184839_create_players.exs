defmodule Listudy.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string
      add :slug, :string
      add :description, :string
      add :title, :string

      timestamps()
    end

    create unique_index(:players, [:slug])
  end
end

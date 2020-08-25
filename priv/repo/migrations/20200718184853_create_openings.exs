defmodule Listudy.Repo.Migrations.CreateOpenings do
  use Ecto.Migration

  def change do
    create table(:openings) do
      add :name, :string
      add :slug, :string
      add :description, :string
      add :eco, :string
      add :moves, :string

      timestamps()
    end

    create unique_index(:openings, [:name])
    create unique_index(:openings, [:slug])
  end
end

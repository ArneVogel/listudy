defmodule Listudy.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :slug, :string
      add :description, :string

      timestamps()
    end

    create unique_index(:events, [:name])
    create unique_index(:events, [:slug])
  end
end

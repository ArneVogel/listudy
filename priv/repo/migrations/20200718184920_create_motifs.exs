defmodule Listudy.Repo.Migrations.CreateMotifs do
  use Ecto.Migration

  def change do
    create table(:motifs) do
      add :name, :string
      add :slug, :string
      add :description, :string

      timestamps()
    end

    create unique_index(:motifs, [:name])
    create unique_index(:motifs, [:slug])
  end
end

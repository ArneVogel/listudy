defmodule Listudy.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :title, :string
      add :slug, :string
      add :summary, :text
      add :description, :text

      timestamps()
    end

  end
end

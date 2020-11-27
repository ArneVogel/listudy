defmodule Listudy.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string
      add :slug, :string
      add :description, :text

      timestamps()
    end

  end
end

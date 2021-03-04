defmodule Listudy.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :images, :string
      add :alt, :string

      timestamps()
    end
  end
end

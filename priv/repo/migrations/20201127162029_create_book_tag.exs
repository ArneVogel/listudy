defmodule Listudy.Repo.Migrations.CreateBookTag do
  use Ecto.Migration

  def change do
    create table(:book_tag) do
      add :book, references(:books, on_delete: :nothing)
      add :tag, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:book_tag, [:book])
    create index(:book_tag, [:tag])
  end
end

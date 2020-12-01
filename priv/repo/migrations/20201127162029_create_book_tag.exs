defmodule Listudy.Repo.Migrations.CreateBookTag do
  use Ecto.Migration

  def change do
    create table(:book_tag) do
      add :book_id, references(:books, on_delete: :nothing)
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:book_tag, [:book_id])
    create index(:book_tag, [:tag_id])
  end
end

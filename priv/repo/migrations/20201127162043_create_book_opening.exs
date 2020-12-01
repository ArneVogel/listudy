defmodule Listudy.Repo.Migrations.CreateBookOpening do
  use Ecto.Migration

  def change do
    create table(:book_opening) do
      add :book_id, references(:books, on_delete: :nothing)
      add :opening_id, references(:openings, on_delete: :nothing)

      timestamps()
    end

    create index(:book_opening, [:book_id])
    create index(:book_opening, [:opening_id])
  end
end

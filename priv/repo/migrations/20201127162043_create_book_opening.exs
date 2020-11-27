defmodule Listudy.Repo.Migrations.CreateBookOpening do
  use Ecto.Migration

  def change do
    create table(:book_opening) do
      add :book, references(:books, on_delete: :nothing)
      add :opening, references(:openings, on_delete: :nothing)

      timestamps()
    end

    create index(:book_opening, [:book])
    create index(:book_opening, [:opening])
  end
end

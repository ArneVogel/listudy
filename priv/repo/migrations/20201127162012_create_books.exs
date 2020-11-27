defmodule Listudy.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :slug, :string
      add :year, :integer
      add :isbn, :string
      add :amazon_id, :string
      add :summary, :text
      add :text, :text
      add :author, references(:authors, on_delete: :nothing)

      timestamps()
    end

    create index(:books, [:author])
  end
end

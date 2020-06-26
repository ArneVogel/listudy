defmodule Listudy.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :slug, :string
      add :body, :text
      add :published, :boolean, default: false, null: false
      add :author_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:posts, [:title])
    create unique_index(:posts, [:slug])
    create index(:posts, [:author_id])
  end
end

defmodule Listudy.Repo.Migrations.CreatePostComments do
  use Ecto.Migration

  def change do
    create table(:post_comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :text, :string
      add :post_id, references(:posts, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:post_comments, [:post_id])
    create index(:post_comments, [:user_id])
  end
end

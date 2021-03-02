defmodule Listudy.Repo.Migrations.CreateBlogFaq do
  use Ecto.Migration

  def change do
    create table(:blog_faq) do
      add :question, :text
      add :answer, :text
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end

    create index(:blog_faq, [:post_id])
  end
end

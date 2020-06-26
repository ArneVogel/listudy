defmodule Listudy.Repo.Migrations.CreateStudies do
  use Ecto.Migration

  def change do
    create table("studies") do
      add :title, :string
      add :description, :text
      add :slug, :string
      add :private, :boolean
      add :color, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index("studies", ["title"], comment: "Title is used for search")
  end
end

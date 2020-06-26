defmodule Listudy.Repo.Migrations.CreateStudyFavorites do
  use Ecto.Migration

  def change do
    create table(:study_favorites) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :study_id, references(:studies, on_delete: :delete_all)

      timestamps()
    end

    create index(:study_favorites, [:user_id])
    create index(:study_favorites, [:study_id])
    create unique_index(:study_favorites, [:user_id, :study_id], name: :favorite_once)
  end
end

defmodule Listudy.Repo.Migrations.CreateStudyComments do
  use Ecto.Migration

  def change do
    create table(:study_comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :text, :string
      add :study_id, references(:studies, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:study_comments, [:study_id])
    create index(:study_comments, [:user_id])
  end
end

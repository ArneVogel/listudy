defmodule Listudy.Repo.Migrations.CreateExpertRecommendation do
  use Ecto.Migration

  def change do
    create table(:expert_recommendation) do
      add :text, :text
      add :source, :text
      add :player_id, references(:players, on_delete: :nothing)
      add :book_id, references(:books, on_delete: :nothing)

      timestamps()
    end

    create index(:expert_recommendation, [:player_id])
    create index(:expert_recommendation, [:book_id])
  end
end

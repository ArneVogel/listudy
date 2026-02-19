defmodule Listudy.Repo.Migrations.CreateOpeningFaq do
  use Ecto.Migration

  def change do
    create table(:opening_faq) do
      add :question, :text
      add :answer, :text
      add :opening_id, references(:openings, on_delete: :nothing)

      timestamps()
    end

    create index(:opening_faq, [:opening_id])
  end
end

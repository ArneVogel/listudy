defmodule Listudy.Repo.Migrations.MakeDescriptionText do
  use Ecto.Migration

  def change do
    alter table(:openings) do
      modify :description, :text
    end

    alter table(:motifs) do
      modify :description, :text
    end

    alter table(:events) do
      modify :description, :text
    end

    alter table(:players) do
      modify :description, :text
    end
  end
end

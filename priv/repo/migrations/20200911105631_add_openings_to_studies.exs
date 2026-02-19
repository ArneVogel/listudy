defmodule Listudy.Repo.Migrations.AddOpeningsToStudies do
  use Ecto.Migration

  def change do
    alter table("studies") do
      add :opening_id, references("openings"), default: 1
    end
  end
end

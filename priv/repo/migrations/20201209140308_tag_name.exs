defmodule Listudy.Repo.Migrations.TagName do
  use Ecto.Migration

  def change do
    alter table("tags") do
      add :name, :text
    end
  end
end

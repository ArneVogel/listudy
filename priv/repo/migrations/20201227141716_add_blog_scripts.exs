defmodule Listudy.Repo.Migrations.AddBlogScripts do
  use Ecto.Migration

  def change do
    alter table("posts") do
      add :script, :text
    end
  end
end

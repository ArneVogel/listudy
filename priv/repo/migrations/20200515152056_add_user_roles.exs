defmodule Listudy.Repo.Migrations.AddUserRoles do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :role, :text, default: "user"
    end
  end
end

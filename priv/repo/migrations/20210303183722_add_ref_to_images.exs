defmodule Listudy.Repo.Migrations.AddRefToImages do
  use Ecto.Migration

  def change do
    alter table("images") do
      add :ref, :string
    end

  end
end

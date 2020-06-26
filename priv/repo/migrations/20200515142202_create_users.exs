defmodule Listudy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string
      add :username, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, ["lower(username)"], name: :unique_user, unique: true)
  end
end

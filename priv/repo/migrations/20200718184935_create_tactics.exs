defmodule Listudy.Repo.Migrations.CreateTactics do
  use Ecto.Migration

  def change do
    create table(:tactics) do
      add :fen, :string
      add :moves, :string
      add :color, :string
      add :link, :string
      add :description, :string
      add :rating, :integer
      add :played, :integer
      add :white, references(:players, on_delete: :nothing)
      add :black, references(:players, on_delete: :nothing)
      add :event, references(:events, on_delete: :nothing)
      add :opening, references(:openings, on_delete: :nothing)
      add :motif, references(:motifs, on_delete: :nothing)

      timestamps()
    end

    create index(:tactics, [:white])
    create index(:tactics, [:black])
    create index(:tactics, [:event])
    create index(:tactics, [:opening])
    create index(:tactics, [:motif])
  end
end

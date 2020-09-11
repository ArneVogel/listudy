defmodule Listudy.Studies.Study do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :slug}
  schema "studies" do
    field :description, :string
    field :title, :string
    field :slug, :string
    field :color, :string
    field :private, :boolean
    field :user_id, :id
    field :opening_id, :id

    timestamps()
  end

  @doc false
  def changeset(study, attrs) do
    study
    |> cast(attrs, [:title, :description, :slug, :private, :user_id, :color, :opening_id])
    |> validate_required([:title, :description, :slug])
    |> validate_length(:title, min: 3, max: 100)
    |> validate_length(:description, min: 10, max: 1000)
  end
end

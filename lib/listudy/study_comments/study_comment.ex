defmodule Listudy.StudyComments.StudyComment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "study_comments" do
    field :text, :string
    field :study_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(study_comment, attrs) do
    study_comment
    |> cast(attrs, [:text, :study_id, :user_id])
    |> validate_required([:text, :study_id, :user_id])
    |> validate_length(:text, min: 4, max: 500)
  end
end

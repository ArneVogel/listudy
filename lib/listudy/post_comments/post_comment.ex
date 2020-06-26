defmodule Listudy.PostComments.PostComment do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "post_comments" do
    field :text, :string
    field :post_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(post_comment, attrs) do
    post_comment
    |> cast(attrs, [:text, :post_id, :user_id])
    |> validate_required([:text, :post_id, :user_id])
    |> validate_length(:text, min: 4, max: 500)
  end
end

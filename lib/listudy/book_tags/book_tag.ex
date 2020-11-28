defmodule Listudy.BookTags.BookTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_tag" do
    field :book_id, :id
    field :tag_id, :id

    timestamps()
  end

  @doc false
  def changeset(book_tag, attrs) do
    book_tag
    |> cast(attrs, [:book_id, :tag_id])
    |> validate_required([:book_id, :tag_id])
  end
end

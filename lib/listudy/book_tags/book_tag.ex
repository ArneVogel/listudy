defmodule Listudy.BookTags.BookTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_tag" do
    field :book, :id
    field :tag, :id

    timestamps()
  end

  @doc false
  def changeset(book_tag, attrs) do
    book_tag
    |> cast(attrs, [:book, :tag])
    |> validate_required([:book, :tag])
  end
end

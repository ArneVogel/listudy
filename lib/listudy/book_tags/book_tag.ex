defmodule Listudy.BookTags.BookTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_tag" do
    belongs_to(:book, Listudy.Books.Book)
    belongs_to(:tag, Listudy.Tags.Tag)

    timestamps()
  end

  @doc false
  def changeset(book_tag, attrs) do
    book_tag
    |> cast(attrs, [:book_id, :tag_id])
    |> validate_required([:book_id, :tag_id])
  end
end

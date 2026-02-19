defmodule Listudy.BookOpenings.BookOpening do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_opening" do
    field :book_id, :id
    field :opening_id, :id

    timestamps()
  end

  @doc false
  def changeset(book_opening, attrs) do
    book_opening
    |> cast(attrs, [:book_id, :opening_id])
    |> validate_required([:book_id, :opening_id])
  end
end

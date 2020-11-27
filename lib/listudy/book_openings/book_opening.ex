defmodule Listudy.BookOpenings.BookOpening do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_opening" do
    field :book, :id
    field :opening, :id

    timestamps()
  end

  @doc false
  def changeset(book_opening, attrs) do
    book_opening
    |> cast(attrs, [:book, :opening])
    |> validate_required([:book, :opening])
  end
end

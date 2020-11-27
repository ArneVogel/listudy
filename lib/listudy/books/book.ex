defmodule Listudy.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :amazon_id, :string
    field :isbn, :string
    field :slug, :string
    field :summary, :string
    field :text, :string
    field :title, :string
    field :year, :integer
    field :author, :id

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :slug, :year, :isbn, :amazon_id, :summary, :text, :author])
    |> validate_required([:title, :slug, :year, :isbn, :amazon_id, :summary, :text, :author])
  end
end

defmodule Listudy.Books.Book do
  use Ecto.Schema
  alias Listudy.Authors.Author
  import Ecto.Changeset

  schema "books" do
    field :amazon_id, :string
    field :isbn, :string
    field :slug, :string
    field :summary, :string
    field :text, :string
    field :title, :string
    field :year, :integer
    belongs_to(:author, Author)

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :slug, :year, :isbn, :amazon_id, :summary, :text, :author_id])
    |> validate_required([:title, :slug, :year, :isbn, :amazon_id, :summary, :text, :author_id])
  end
end

defmodule Listudy.BlogFaqs.BlogFaq do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_faq" do
    field :answer, :string
    field :question, :string
    field :post_id, :id

    timestamps()
  end

  @doc false
  def changeset(blog_faq, attrs) do
    blog_faq
    |> cast(attrs, [:question, :answer])
    |> validate_required([:question, :answer])
  end
end

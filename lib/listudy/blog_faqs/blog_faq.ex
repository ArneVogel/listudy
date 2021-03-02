defmodule Listudy.BlogFaqs.BlogFaq do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_faq" do
    field :answer, :string
    field :question, :string
    belongs_to(:post, Listudy.Content.Post)

    timestamps()
  end

  @doc false
  def changeset(blog_faq, attrs) do
    blog_faq
    |> cast(attrs, [:post_id, :question, :answer])
    |> validate_required([:question, :answer, :post_id])
  end
end

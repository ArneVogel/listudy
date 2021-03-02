defmodule Listudy.OpeningFaqs.OpeningFaq do
  use Ecto.Schema
  import Ecto.Changeset

  schema "opening_faq" do
    field :answer, :string
    field :question, :string
    field :opening_id, :id

    timestamps()
  end

  @doc false
  def changeset(opening_faq, attrs) do
    opening_faq
    |> cast(attrs, [:question, :answer])
    |> validate_required([:question, :answer])
  end
end

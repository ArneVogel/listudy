defmodule Listudy.OpeningFaqs.OpeningFaq do
  use Ecto.Schema
  import Ecto.Changeset

  schema "opening_faq" do
    field :answer, :string
    field :question, :string
    belongs_to(:opening, Listudy.Openings.Opening)

    timestamps()
  end

  @doc false
  def changeset(opening_faq, attrs) do
    opening_faq
    |> cast(attrs, [:question, :answer, :opening_id])
    |> validate_required([:question, :answer, :opening_id])
  end
end

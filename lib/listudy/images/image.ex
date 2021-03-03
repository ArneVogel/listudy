defmodule Listudy.Images.Image do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :alt, :string
    field :images, Listudy.Image.Type

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:images, :alt])
    |> cast_attachments(attrs, [:images])
    |> validate_required([:images, :alt])
  end
end

defmodule Listudy.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  import ListudyWeb.Gettext

  schema "users" do
    field :username, :string, null: false
    field :role, :string, null: false, default: "user"
    pow_user_fields()
    field :last_visited, :utc_datetime

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    import Ecto.Changeset

    user_or_changeset
    |> pow_changeset(attrs)
    |> Ecto.Changeset.cast(attrs, [:username, :role])
    |> Ecto.Changeset.validate_required([:username])
    |> unique_constraint([:username])
    |> unique_constraint([:email])
    |> unique_constraint(:unique_user, name: :unique_user)
    |> Ecto.Changeset.validate_inclusion(:role, ~w(user))
    |> validate_alphanumeric(:username)
    |> validate_length(:username, min: 3, max: 20)
  end

  defp validate_alphanumeric(changeset, field, _options \\ []) do
    case changeset.valid? do
      true ->
        value = Ecto.Changeset.get_field(changeset, field)

        case String.match?(value, ~r/^[[:alnum:]]+$/) do
          true ->
            changeset

          _ ->
            Ecto.Changeset.add_error(
              changeset,
              field,
              gettext("Only alphanumeric characters allowed")
            )
        end

      _ ->
        changeset
    end
  end
end

defmodule Listudy.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo
  alias Listudy.Helpers

  alias Listudy.Users.User

  def get_user_by_name!(username), do: Repo.get_by(User, username: username)

  def get_user!(id), do: Repo.get!(User, id)

  def user_aggregate() do
    User
    |> Helpers.count_by_month(:inserted_at)
    |> Repo.all()
  end

  def visited_now(id) do
    get_user!(id)
    |> Ecto.Changeset.change(%{last_visited: DateTime.truncate(DateTime.utc_now(), :second)})
    |> Repo.update()
  end

  # Returns a changeset
  def admin_change_user(%User{} = user, attrs \\ %{}) do
    User.admin_changeset(user, attrs)
  end

  # Returns a changeset
  # See https://github.com/danschultzer/pow/issues/614
  def admin_change_password(%User{} = user, attrs \\ %{}) do
    PowResetPassword.Ecto.Schema.reset_password_changeset(user, attrs)
  end

  def admin_update_user(%User{} = user, attrs) do
    changeset = User.admin_changeset(user, attrs)
    Repo.update(changeset)
  end

  def admin_update_password(%User{} = user, attrs) do
    changeset = admin_change_password(user, attrs)
    Repo.update(changeset)
  end
end

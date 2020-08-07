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
      |> Repo.all
  end

  def visited_now(id) do
    get_user!(id)
      |> Ecto.Changeset.change(%{last_visited: DateTime.truncate(DateTime.utc_now, :second)})
      |> Repo.update()
  end
end

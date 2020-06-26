defmodule Listudy.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.Users.User

  def get_user_by_name!(username), do: Repo.get_by(User, username: username)

  def get_user!(id), do: Repo.get!(User, id)

end

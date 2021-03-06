defmodule ListudyWeb.UserAdministrationController do
  use ListudyWeb, :controller

  alias Listudy.Users

  def email(conn, %{"username" => username}) do
    user = Users.get_user_by_name!(username)
    changeset = Users.admin_change_user(user)

    render(conn, "email.html", user: user, changeset: changeset)
  end

  def update_email(conn, %{"username" => username, "user" => user_params}) do
    user = Users.get_user_by_name!(username)

    case Users.admin_update_user(user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Changed!")
        |> redirect(to: Routes.user_administration_path(conn, :email, user.username))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Not Changed")
        |> render("email.html", user: user, changeset: changeset)
    end
  end

  def password(conn, %{"username" => username}) do
    user = Users.get_user_by_name!(username)
    changeset = Users.admin_change_password(user)
    render(conn, "password.html", user: user, changeset: changeset)
  end

  def update_password(conn, %{"username" => username, "user" => user_params}) do
    user = Users.get_user_by_name!(username)
    password = user_params["password"]
    user_params = Map.put(user_params, "password_confirmation", password)

    case Users.admin_update_password(user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Changed!")
        |> redirect(to: Routes.user_administration_path(conn, :password, user.username))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Not Changed")
        |> render("password.html", user: user, changeset: changeset)
    end
  end
end

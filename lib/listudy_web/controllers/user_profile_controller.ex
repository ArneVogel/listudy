defmodule ListudyWeb.UserProfileController do
  use ListudyWeb, :controller

  alias Listudy.Studies
  alias Listudy.Users

  def show(conn, %{"username" => username}) do
    user = Users.get_user_by_name!(username)

    case user do
      nil ->
        conn
        |> put_flash(:info, "This user does not exist")
        |> redirect(to: Routes.page_path(conn, :index, conn.private.plug_session["locale"]))

      _ ->
        studies = Studies.get_public_studies_by_user!(user.id)
        render(conn, "show.html", studies: studies, user: user, noindex: true)
    end
  end
end

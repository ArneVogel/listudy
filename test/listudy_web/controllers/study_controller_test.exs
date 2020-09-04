defmodule ListudyWeb.StudyControllerTest do
  use ListudyWeb.ConnCase
  use ListudyWeb, :controller

  setup %{conn: conn} do
    user = %Listudy.Users.User{
      username: "Arne",
      id: 1
    }

    regular_user = %Listudy.Users.User{
      username: "Regular",
      id: 2
    }

    admin_conn = Pow.Plug.assign_current_user(conn, user, [])
    regular_user_conn = Pow.Plug.assign_current_user(conn, regular_user, [])

    {:ok, conn: conn, admin_conn: admin_conn, regular_user_conn: regular_user_conn}
  end

  test "Your Studies is shown", %{conn: conn} do
    conn = get(conn, Routes.study_path(conn, :index, "en"))
    assert html_response(conn, 200) =~ "Studies"
  end

  test "New Study as user", %{regular_user_conn: conn} do
    conn = get(conn, Routes.study_path(conn, :new, "en"))
    assert html_response(conn, 200) =~ "Studies"
  end

  test "New Study as logged out user redirects", %{conn: conn} do
    conn = get(conn, Routes.study_path(conn, :new, "en"))
    assert html_response(conn, 302) =~ "redirect"
  end
end

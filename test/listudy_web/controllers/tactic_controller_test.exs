defmodule ListudyWeb.TacticControllerTest do
  use ListudyWeb.ConnCase
  use ListudyWeb, :controller

  setup %{conn: conn} do
    user = %Listudy.Users.User{
      username: "Arne",
      id: 1,
      role: "admin"
    }

    regular_user = %Listudy.Users.User{
      username: "Regular",
      id: 2
    }

    admin_conn = Pow.Plug.assign_current_user(conn, user, [])
    regular_user_conn = Pow.Plug.assign_current_user(conn, regular_user, [])

    {:ok, conn: conn, admin_conn: admin_conn, regular_user_conn: regular_user_conn}
  end

  test "Custom Tactics page exists", %{conn: conn} do
    conn = get(conn, Routes.tactic_path(conn, :custom, "en"))
    assert html_response(conn, 200) =~ "Custom"
  end

  test "Custom Tactics page exists, logged in user", %{regular_user_conn: conn} do
    conn = get(conn, Routes.tactic_path(conn, :custom, "en"))
    assert html_response(conn, 200) =~ "Custom"
  end
end

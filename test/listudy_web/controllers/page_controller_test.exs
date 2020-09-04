defmodule ListudyWeb.PageControllerTest do
  use ListudyWeb.ConnCase

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

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /en", %{conn: conn} do
    conn = get(conn, "/en")
    assert html_response(conn, 200) =~ "Listudy"
  end

  test "admin GET /en", %{admin_conn: conn} do
    conn = get(conn, "/en")
    assert html_response(conn, 200) =~ "registration/edit"
  end

  test "regular user GET /en", %{regular_user_conn: conn} do
    conn = get(conn, "/en")
    assert html_response(conn, 200) =~ "registration/edit"
  end

  test "logged out GET /en", %{conn: conn} do
    conn = get(conn, "/en")
    assert !(html_response(conn, 200) =~ "registration/edit")
    assert html_response(conn, 200) =~ "Register"
  end

  test "GET /de", %{conn: conn} do
    conn = get(conn, "/de")
    assert html_response(conn, 200) =~ "Listudy"
  end

  test "GET /abcdefghi_I_do_not_exist", %{conn: conn} do
    conn = get(conn, "/abcdefghi_I_do_not_exist")
    assert html_response(conn, 302) =~ "/en"
  end

  test "GET /en/privacy", %{conn: conn} do
    conn = get(conn, "/en/privacy")
    assert html_response(conn, 200) =~ "Privacy"
    assert html_response(conn, 200) =~ "Policy"
  end

  test "GET /en/terms-of-service", %{conn: conn} do
    conn = get(conn, "/en/terms-of-service")
    assert html_response(conn, 200) =~ "Terms"
  end

  test "GET /en/copyright", %{conn: conn} do
    conn = get(conn, "/en/copyright")
    assert html_response(conn, 200) =~ "Copyright"
  end

  test "GET /en/imprint", %{conn: conn} do
    conn = get(conn, "/en/imprint")
    assert html_response(conn, 200) =~ "Imprint"
  end

  test "GET /en/features/blind-tactics", %{conn: conn} do
    conn = get(conn, "/en/features/blind-tactics")
    assert html_response(conn, 200) =~ "Blind"
  end
end

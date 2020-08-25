defmodule ListudyWeb.OpeningControllerTest do
  use ListudyWeb.ConnCase

  alias Listudy.Openings

  @create_attrs %{description: "some description", eco: "some eco", moves: "some moves", name: "some name", slug: "some slug"}
  @update_attrs %{description: "some updated description", eco: "some updated eco", moves: "some updated moves", name: "some updated name", slug: "some updated slug"}
  @invalid_attrs %{description: nil, eco: nil, moves: nil, name: nil, slug: nil}

  def fixture(:opening) do
    {:ok, opening} = Openings.create_opening(@create_attrs)
    opening
  end

  describe "index" do
    test "lists all openings", %{conn: conn} do
      conn = get(conn, Routes.opening_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Openings"
    end
  end

  describe "new opening" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.opening_path(conn, :new))
      assert html_response(conn, 200) =~ "New Opening"
    end
  end

  describe "create opening" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.opening_path(conn, :create), opening: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.opening_path(conn, :show, id)

      conn = get(conn, Routes.opening_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Opening"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.opening_path(conn, :create), opening: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Opening"
    end
  end

  describe "edit opening" do
    setup [:create_opening]

    test "renders form for editing chosen opening", %{conn: conn, opening: opening} do
      conn = get(conn, Routes.opening_path(conn, :edit, opening))
      assert html_response(conn, 200) =~ "Edit Opening"
    end
  end

  describe "update opening" do
    setup [:create_opening]

    test "redirects when data is valid", %{conn: conn, opening: opening} do
      conn = put(conn, Routes.opening_path(conn, :update, opening), opening: @update_attrs)
      assert redirected_to(conn) == Routes.opening_path(conn, :show, opening)

      conn = get(conn, Routes.opening_path(conn, :show, opening))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, opening: opening} do
      conn = put(conn, Routes.opening_path(conn, :update, opening), opening: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Opening"
    end
  end

  describe "delete opening" do
    setup [:create_opening]

    test "deletes chosen opening", %{conn: conn, opening: opening} do
      conn = delete(conn, Routes.opening_path(conn, :delete, opening))
      assert redirected_to(conn) == Routes.opening_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.opening_path(conn, :show, opening))
      end
    end
  end

  defp create_opening(_) do
    opening = fixture(:opening)
    %{opening: opening}
  end
end

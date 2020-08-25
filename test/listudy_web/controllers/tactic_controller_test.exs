defmodule ListudyWeb.TacticControllerTest do
  use ListudyWeb.ConnCase

  alias Listudy.Tactics

  @create_attrs %{color: "some color", description: "some description", fen: "some fen", link: "some link", moves: "some moves", played: 42, rating: 42}
  @update_attrs %{color: "some updated color", description: "some updated description", fen: "some updated fen", link: "some updated link", moves: "some updated moves", played: 43, rating: 43}
  @invalid_attrs %{color: nil, description: nil, fen: nil, link: nil, moves: nil, played: nil, rating: nil}

  def fixture(:tactic) do
    {:ok, tactic} = Tactics.create_tactic(@create_attrs)
    tactic
  end

  describe "index" do
    test "lists all tactics", %{conn: conn} do
      conn = get(conn, Routes.tactic_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tactics"
    end
  end

  describe "new tactic" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.tactic_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tactic"
    end
  end

  describe "create tactic" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tactic_path(conn, :create), tactic: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.tactic_path(conn, :show, id)

      conn = get(conn, Routes.tactic_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Tactic"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.tactic_path(conn, :create), tactic: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tactic"
    end
  end

  describe "edit tactic" do
    setup [:create_tactic]

    test "renders form for editing chosen tactic", %{conn: conn, tactic: tactic} do
      conn = get(conn, Routes.tactic_path(conn, :edit, tactic))
      assert html_response(conn, 200) =~ "Edit Tactic"
    end
  end

  describe "update tactic" do
    setup [:create_tactic]

    test "redirects when data is valid", %{conn: conn, tactic: tactic} do
      conn = put(conn, Routes.tactic_path(conn, :update, tactic), tactic: @update_attrs)
      assert redirected_to(conn) == Routes.tactic_path(conn, :show, tactic)

      conn = get(conn, Routes.tactic_path(conn, :show, tactic))
      assert html_response(conn, 200) =~ "some updated color"
    end

    test "renders errors when data is invalid", %{conn: conn, tactic: tactic} do
      conn = put(conn, Routes.tactic_path(conn, :update, tactic), tactic: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Tactic"
    end
  end

  describe "delete tactic" do
    setup [:create_tactic]

    test "deletes chosen tactic", %{conn: conn, tactic: tactic} do
      conn = delete(conn, Routes.tactic_path(conn, :delete, tactic))
      assert redirected_to(conn) == Routes.tactic_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.tactic_path(conn, :show, tactic))
      end
    end
  end

  defp create_tactic(_) do
    tactic = fixture(:tactic)
    %{tactic: tactic}
  end
end

defmodule ListudyWeb.PiecelessTacticControllerTest do
  use ListudyWeb.ConnCase

  alias Listudy.PiecelessTactics

  @create_attrs %{fen: "some fen", pieces: 42, solution: "some solution"}
  @update_attrs %{fen: "some updated fen", pieces: 43, solution: "some updated solution"}
  @invalid_attrs %{fen: nil, pieces: nil, solution: nil}

  def fixture(:pieceless_tactic) do
    {:ok, pieceless_tactic} = PiecelessTactics.create_pieceless_tactic(@create_attrs)
    pieceless_tactic
  end

  describe "index" do
    test "lists all piecelesstactic", %{conn: conn} do
      conn = get(conn, Routes.pieceless_tactic_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Piecelesstactic"
    end
  end

  describe "new pieceless_tactic" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.pieceless_tactic_path(conn, :new))
      assert html_response(conn, 200) =~ "New Pieceless tactic"
    end
  end

  describe "create pieceless_tactic" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.pieceless_tactic_path(conn, :create), pieceless_tactic: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.pieceless_tactic_path(conn, :show, id)

      conn = get(conn, Routes.pieceless_tactic_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Pieceless tactic"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.pieceless_tactic_path(conn, :create), pieceless_tactic: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Pieceless tactic"
    end
  end

  describe "edit pieceless_tactic" do
    setup [:create_pieceless_tactic]

    test "renders form for editing chosen pieceless_tactic", %{conn: conn, pieceless_tactic: pieceless_tactic} do
      conn = get(conn, Routes.pieceless_tactic_path(conn, :edit, pieceless_tactic))
      assert html_response(conn, 200) =~ "Edit Pieceless tactic"
    end
  end

  describe "update pieceless_tactic" do
    setup [:create_pieceless_tactic]

    test "redirects when data is valid", %{conn: conn, pieceless_tactic: pieceless_tactic} do
      conn = put(conn, Routes.pieceless_tactic_path(conn, :update, pieceless_tactic), pieceless_tactic: @update_attrs)
      assert redirected_to(conn) == Routes.pieceless_tactic_path(conn, :show, pieceless_tactic)

      conn = get(conn, Routes.pieceless_tactic_path(conn, :show, pieceless_tactic))
      assert html_response(conn, 200) =~ "some updated fen"
    end

    test "renders errors when data is invalid", %{conn: conn, pieceless_tactic: pieceless_tactic} do
      conn = put(conn, Routes.pieceless_tactic_path(conn, :update, pieceless_tactic), pieceless_tactic: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Pieceless tactic"
    end
  end

  describe "delete pieceless_tactic" do
    setup [:create_pieceless_tactic]

    test "deletes chosen pieceless_tactic", %{conn: conn, pieceless_tactic: pieceless_tactic} do
      conn = delete(conn, Routes.pieceless_tactic_path(conn, :delete, pieceless_tactic))
      assert redirected_to(conn) == Routes.pieceless_tactic_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.pieceless_tactic_path(conn, :show, pieceless_tactic))
      end
    end
  end

  defp create_pieceless_tactic(_) do
    pieceless_tactic = fixture(:pieceless_tactic)
    %{pieceless_tactic: pieceless_tactic}
  end
end

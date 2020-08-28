defmodule ListudyWeb.BlindTacticControllerTest do
  use ListudyWeb.ConnCase

  alias Listudy.BlindTactics

  @create_attrs %{color: "some color", description: "some description", pgn: "some pgn", played: 42, ply: 42}
  @update_attrs %{color: "some updated color", description: "some updated description", pgn: "some updated pgn", played: 43, ply: 43}
  @invalid_attrs %{color: nil, description: nil, pgn: nil, played: nil, ply: nil}

  def fixture(:blind_tactic) do
    {:ok, blind_tactic} = BlindTactics.create_blind_tactic(@create_attrs)
    blind_tactic
  end

  describe "index" do
    test "lists all blind_tactics", %{conn: conn} do
      conn = get(conn, Routes.blind_tactic_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Blind tactics"
    end
  end

  describe "new blind_tactic" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.blind_tactic_path(conn, :new))
      assert html_response(conn, 200) =~ "New Blind tactic"
    end
  end

  describe "create blind_tactic" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.blind_tactic_path(conn, :create), blind_tactic: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.blind_tactic_path(conn, :show, id)

      conn = get(conn, Routes.blind_tactic_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Blind tactic"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.blind_tactic_path(conn, :create), blind_tactic: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Blind tactic"
    end
  end

  describe "edit blind_tactic" do
    setup [:create_blind_tactic]

    test "renders form for editing chosen blind_tactic", %{conn: conn, blind_tactic: blind_tactic} do
      conn = get(conn, Routes.blind_tactic_path(conn, :edit, blind_tactic))
      assert html_response(conn, 200) =~ "Edit Blind tactic"
    end
  end

  describe "update blind_tactic" do
    setup [:create_blind_tactic]

    test "redirects when data is valid", %{conn: conn, blind_tactic: blind_tactic} do
      conn = put(conn, Routes.blind_tactic_path(conn, :update, blind_tactic), blind_tactic: @update_attrs)
      assert redirected_to(conn) == Routes.blind_tactic_path(conn, :show, blind_tactic)

      conn = get(conn, Routes.blind_tactic_path(conn, :show, blind_tactic))
      assert html_response(conn, 200) =~ "some updated color"
    end

    test "renders errors when data is invalid", %{conn: conn, blind_tactic: blind_tactic} do
      conn = put(conn, Routes.blind_tactic_path(conn, :update, blind_tactic), blind_tactic: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Blind tactic"
    end
  end

  describe "delete blind_tactic" do
    setup [:create_blind_tactic]

    test "deletes chosen blind_tactic", %{conn: conn, blind_tactic: blind_tactic} do
      conn = delete(conn, Routes.blind_tactic_path(conn, :delete, blind_tactic))
      assert redirected_to(conn) == Routes.blind_tactic_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.blind_tactic_path(conn, :show, blind_tactic))
      end
    end
  end

  defp create_blind_tactic(_) do
    blind_tactic = fixture(:blind_tactic)
    %{blind_tactic: blind_tactic}
  end
end

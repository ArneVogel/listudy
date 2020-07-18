defmodule ListudyWeb.MotifControllerTest do
  use ListudyWeb.ConnCase

  alias Listudy.Motifs

  @create_attrs %{description: "some description", name: "some name", slug: "some slug"}
  @update_attrs %{description: "some updated description", name: "some updated name", slug: "some updated slug"}
  @invalid_attrs %{description: nil, name: nil, slug: nil}

  def fixture(:motif) do
    {:ok, motif} = Motifs.create_motif(@create_attrs)
    motif
  end

  describe "index" do
    test "lists all motifs", %{conn: conn} do
      conn = get(conn, Routes.motif_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Motifs"
    end
  end

  describe "new motif" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.motif_path(conn, :new))
      assert html_response(conn, 200) =~ "New Motif"
    end
  end

  describe "create motif" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.motif_path(conn, :create), motif: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.motif_path(conn, :show, id)

      conn = get(conn, Routes.motif_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Motif"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.motif_path(conn, :create), motif: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Motif"
    end
  end

  describe "edit motif" do
    setup [:create_motif]

    test "renders form for editing chosen motif", %{conn: conn, motif: motif} do
      conn = get(conn, Routes.motif_path(conn, :edit, motif))
      assert html_response(conn, 200) =~ "Edit Motif"
    end
  end

  describe "update motif" do
    setup [:create_motif]

    test "redirects when data is valid", %{conn: conn, motif: motif} do
      conn = put(conn, Routes.motif_path(conn, :update, motif), motif: @update_attrs)
      assert redirected_to(conn) == Routes.motif_path(conn, :show, motif)

      conn = get(conn, Routes.motif_path(conn, :show, motif))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, motif: motif} do
      conn = put(conn, Routes.motif_path(conn, :update, motif), motif: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Motif"
    end
  end

  describe "delete motif" do
    setup [:create_motif]

    test "deletes chosen motif", %{conn: conn, motif: motif} do
      conn = delete(conn, Routes.motif_path(conn, :delete, motif))
      assert redirected_to(conn) == Routes.motif_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.motif_path(conn, :show, motif))
      end
    end
  end

  defp create_motif(_) do
    motif = fixture(:motif)
    %{motif: motif}
  end
end

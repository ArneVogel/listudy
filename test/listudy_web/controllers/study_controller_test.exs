defmodule ListudyWeb.StudyControllerTest do
  use ListudyWeb.ConnCase

  alias Listudy.Studies

  @create_attrs %{title: "some title", description: "some description", name: "some name", slug: "id-some-slug"}
  @update_attrs %{title: "some updated title", description: "some updated description", name: "some updated name", slug: "id-some-updated-slug"}
  @invalid_attrs %{description: "", title: "", slug: ""}

  def fixture(:study) do
    {:ok, study} = Studies.create_study(@create_attrs)
    study
  end

  describe "index" do
    test "lists all studies", %{conn: conn} do
      conn = get(conn, Routes.study_path(conn, :index, "en"))
      assert html_response(conn, 200) =~ "Listing Studies"
    end
  end

  describe "new study" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.study_path(conn, :new, "en"))
      assert html_response(conn, 302) =~ "some title"
    end
  end

  describe "create study" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.study_path(conn, :create, "en"), study: @create_attrs)


      id = "id-some-study"
      
      conn = get(conn, Routes.study_path(conn, :show, "en", id))
      assert html_response(conn, 200) =~ "Show Study"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.study_path(conn, :create, "en"), study: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Study"
    end
  end

  describe "edit study" do
    setup [:create_study]

    test "renders form for editing chosen study", %{conn: conn, study: study} do
      conn = get(conn, Routes.study_path(conn, :edit, "en", study))
      assert html_response(conn, 200) =~ "Edit Study"
    end
  end

  describe "update study" do
    setup [:create_study]

    test "redirects when data is valid", %{conn: conn, study: study} do
      conn = put(conn, Routes.study_path(conn, :update, "en", study), study: @update_attrs)
      assert redirected_to(conn) == Routes.study_path(conn, :show, "en", study)

      conn = get(conn, Routes.study_path(conn, :show, "en", study))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, study: study} do
      conn = put(conn, Routes.study_path(conn, :update, "en", study), study: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Study"
    end
  end

  describe "delete study" do
    setup [:create_study]

    test "deletes chosen study", %{conn: conn, study: study} do
      conn = delete(conn, Routes.study_path(conn, :delete, "en", study))
      assert redirected_to(conn) == Routes.study_path(conn, :index, "en")
      assert_error_sent 404, fn ->
        get(conn, Routes.study_path(conn, :show, "en", study))
      end
    end
  end

  defp create_study(_) do
    study = fixture(:study)
    %{study: study}
  end
end

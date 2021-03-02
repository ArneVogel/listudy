defmodule ListudyWeb.BlogFaqControllerTest do
  use ListudyWeb.ConnCase

  alias Listudy.BlogFaqs

  @create_attrs %{answer: "some answer", question: "some question"}
  @update_attrs %{answer: "some updated answer", question: "some updated question"}
  @invalid_attrs %{answer: nil, question: nil}

  def fixture(:blog_faq) do
    {:ok, blog_faq} = BlogFaqs.create_blog_faq(@create_attrs)
    blog_faq
  end

  describe "index" do
    test "lists all blog_faq", %{conn: conn} do
      conn = get(conn, Routes.blog_faq_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Blog faq"
    end
  end

  describe "new blog_faq" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.blog_faq_path(conn, :new))
      assert html_response(conn, 200) =~ "New Blog faq"
    end
  end

  describe "create blog_faq" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.blog_faq_path(conn, :create), blog_faq: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.blog_faq_path(conn, :show, id)

      conn = get(conn, Routes.blog_faq_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Blog faq"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.blog_faq_path(conn, :create), blog_faq: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Blog faq"
    end
  end

  describe "edit blog_faq" do
    setup [:create_blog_faq]

    test "renders form for editing chosen blog_faq", %{conn: conn, blog_faq: blog_faq} do
      conn = get(conn, Routes.blog_faq_path(conn, :edit, blog_faq))
      assert html_response(conn, 200) =~ "Edit Blog faq"
    end
  end

  describe "update blog_faq" do
    setup [:create_blog_faq]

    test "redirects when data is valid", %{conn: conn, blog_faq: blog_faq} do
      conn = put(conn, Routes.blog_faq_path(conn, :update, blog_faq), blog_faq: @update_attrs)
      assert redirected_to(conn) == Routes.blog_faq_path(conn, :show, blog_faq)

      conn = get(conn, Routes.blog_faq_path(conn, :show, blog_faq))
      assert html_response(conn, 200) =~ "some updated answer"
    end

    test "renders errors when data is invalid", %{conn: conn, blog_faq: blog_faq} do
      conn = put(conn, Routes.blog_faq_path(conn, :update, blog_faq), blog_faq: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Blog faq"
    end
  end

  describe "delete blog_faq" do
    setup [:create_blog_faq]

    test "deletes chosen blog_faq", %{conn: conn, blog_faq: blog_faq} do
      conn = delete(conn, Routes.blog_faq_path(conn, :delete, blog_faq))
      assert redirected_to(conn) == Routes.blog_faq_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.blog_faq_path(conn, :show, blog_faq))
      end
    end
  end

  defp create_blog_faq(_) do
    blog_faq = fixture(:blog_faq)
    %{blog_faq: blog_faq}
  end
end

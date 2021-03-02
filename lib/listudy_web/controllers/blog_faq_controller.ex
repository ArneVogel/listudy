defmodule ListudyWeb.BlogFaqController do
  use ListudyWeb, :controller

  alias Listudy.BlogFaqs
  alias Listudy.BlogFaqs.BlogFaq

  def index(conn, _params) do
    blog_faq = BlogFaqs.list_blog_faq()
    render(conn, "index.html", blog_faq: blog_faq)
  end

  def new(conn, _params) do
    changeset = BlogFaqs.change_blog_faq(%BlogFaq{})
    posts = Listudy.Content.list_posts()
    render(conn, "new.html", changeset: changeset, posts: posts)
  end

  def create(conn, %{"blog_faq" => blog_faq_params}) do
    case BlogFaqs.create_blog_faq(blog_faq_params) do
      {:ok, blog_faq} ->
        conn
        |> put_flash(:info, "Blog faq created successfully.")
        |> redirect(to: Routes.blog_faq_path(conn, :show, blog_faq))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    blog_faq = BlogFaqs.get_blog_faq!(id)
    render(conn, "show.html", blog_faq: blog_faq)
  end

  def edit(conn, %{"id" => id}) do
    blog_faq = BlogFaqs.get_blog_faq!(id)
    changeset = BlogFaqs.change_blog_faq(blog_faq)
    posts = Listudy.Content.list_posts()
    render(conn, "edit.html", blog_faq: blog_faq, changeset: changeset, posts: posts)
  end

  def update(conn, %{"id" => id, "blog_faq" => blog_faq_params}) do
    blog_faq = BlogFaqs.get_blog_faq!(id)

    case BlogFaqs.update_blog_faq(blog_faq, blog_faq_params) do
      {:ok, blog_faq} ->
        conn
        |> put_flash(:info, "Blog faq updated successfully.")
        |> redirect(to: Routes.blog_faq_path(conn, :show, blog_faq))

      {:error, %Ecto.Changeset{} = changeset} ->
        posts = Listudy.Content.list_posts()
        render(conn, "edit.html", blog_faq: blog_faq, changeset: changeset, posts: posts)
    end
  end

  def delete(conn, %{"id" => id}) do
    blog_faq = BlogFaqs.get_blog_faq!(id)
    {:ok, _blog_faq} = BlogFaqs.delete_blog_faq(blog_faq)

    conn
    |> put_flash(:info, "Blog faq deleted successfully.")
    |> redirect(to: Routes.blog_faq_path(conn, :index))
  end
end

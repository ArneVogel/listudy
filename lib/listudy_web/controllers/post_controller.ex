defmodule ListudyWeb.PostController do
  use ListudyWeb, :controller

  alias Listudy.Content
  alias Listudy.Content.Post

  def index(conn, _params) do
    posts = Content.list_published_posts(100)
    render(conn, "index.html", posts: posts)
  end

  # Shows also unpublished posts
  def index_all(conn, _params) do
    posts = Content.list_posts()
    render(conn, "index_all.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Content.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Content.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, conn.assigns.locale, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => slug}) do
    post = Content.get_published_post_by_slug!(slug)

    case post do
      nil ->
        conn
        |> put_flash(:info, gettext("This post does not exist"))
        |> redirect(to: Routes.post_path(conn, :index, conn.assigns.locale))

      _ ->
        noindex =
          length(String.split(post.body, " ")) <=
            Application.get_env(:listudy, :seo)[:post_min_words]

        render(conn, "show.html", post: post, noindex: noindex)
    end
  end

  def edit(conn, %{"id" => id}) do
    post = Content.get_post_by_slug!(id)
    changeset = Content.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Content.get_post_by_slug!(id)

    case Content.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :edit, post.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Content.get_post_by_slug!(id)
    {:ok, _post} = Content.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index_all))
  end
end

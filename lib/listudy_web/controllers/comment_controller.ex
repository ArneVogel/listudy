defmodule ListudyWeb.CommentController do
  use ListudyWeb, :controller

  alias Listudy.Comments

  def new_comment(conn, params) do
    {_, message} = save_comment(conn, params)

    conn
    |> put_flash(:info, message)
    |> redirect(to: NavigationHistory.last_path(conn))
  end

  def delete_comment(conn, %{"id" => id, "type" => type}) do
    comment = Comments.get_comment!(type, id)
    user = Pow.Plug.current_user(conn).id

    if !allowed_to_comment(comment, user) do
      conn
      |> put_flash(:info, dgettext("comments", "You're not allowed to do that."))
      |> redirect(to: NavigationHistory.last_path(conn))
    else
      {:ok, _} = Comments.delete_comment(type, comment)

      conn
      |> put_flash(:info, dgettext("comments", "Comment deleted successfully."))
      |> redirect(to: NavigationHistory.last_path(conn))
    end
  end

  def get_comments(type, id) do
    Comments.get_comments_by_id(type, id)
  end

  defp save_comment(conn, %{"id" => id, "comment" => text, "type" => type}) do
    user_id = Pow.Plug.current_user(conn).id

    case Comments.create_comment(type, %{user_id: user_id, id: id, text: text}) do
      {:ok, _} ->
        {:ok, dgettext("comments", "Comment created")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:error, dgettext("comments", "Comment could not get created")}
    end
  end

  defp save_comment(_, _) do
    {:error, dgettext("comments", "Error")}
  end

  defp allowed_to_comment(comment, user) do
    comment.user_id == user
  end
end

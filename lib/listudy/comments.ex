defmodule Listudy.Comments do
  @moduledoc """
  The Studies context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.StudyComments.StudyComment
  alias Listudy.PostComments.PostComment
  alias Listudy.Users.User

  def create_comment("study", attrs) do
    attrs = Map.put(attrs, :study_id, attrs.id)
    %StudyComment{}
    |> StudyComment.changeset(attrs)
    |> Repo.insert()
  end
  def create_comment("post", attrs) do
    attrs = Map.put(attrs, :post_id, attrs.id)
    %PostComment{}
    |> PostComment.changeset(attrs)
    |> Repo.insert()
  end

  def delete_comment("study", %StudyComment{} = comment) do
    Repo.delete(comment)
  end
  def delete_comment("post", %PostComment{} = comment) do
    Repo.delete(comment)
  end

  def get_comment!("study", id), do: Repo.get!(StudyComment, id)
  def get_comment!("post", id), do: Repo.get!(PostComment, id)

  def get_comments_by_id("study", id) do
    query = from c in StudyComment,
      join: u in User,
      on: u.id == c.user_id,
      where: c.study_id == ^id,
      select: %{"id" => c.id, "username" => u.username, "comment" => c.text}
    Repo.all(query)
  end
  def get_comments_by_id("post", id) do
    query = from c in PostComment,
      join: u in User,
      on: u.id == c.user_id,
      where: c.post_id == ^id,
      select: %{"id" => c.id, "username" => u.username, "comment" => c.text}
    Repo.all(query)
  end


end

defmodule Listudy.BlogFaqs do
  @moduledoc """
  The BlogFaqs context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.BlogFaqs.BlogFaq

  @doc """
  Returns the list of blog_faq.

  ## Examples

      iex> list_blog_faq()
      [%BlogFaq{}, ...]

  """
  def list_blog_faq do
    Repo.all(BlogFaq)
  end

  @doc """
  Gets a single blog_faq.

  Raises `Ecto.NoResultsError` if the Blog faq does not exist.

  ## Examples

      iex> get_blog_faq!(123)
      %BlogFaq{}

      iex> get_blog_faq!(456)
      ** (Ecto.NoResultsError)

  """
  def get_blog_faq!(id), do: Repo.get!(BlogFaq, id)

  @doc """
  Creates a blog_faq.

  ## Examples

      iex> create_blog_faq(%{field: value})
      {:ok, %BlogFaq{}}

      iex> create_blog_faq(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_blog_faq(attrs \\ %{}) do
    %BlogFaq{}
    |> BlogFaq.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a blog_faq.

  ## Examples

      iex> update_blog_faq(blog_faq, %{field: new_value})
      {:ok, %BlogFaq{}}

      iex> update_blog_faq(blog_faq, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_blog_faq(%BlogFaq{} = blog_faq, attrs) do
    blog_faq
    |> BlogFaq.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a blog_faq.

  ## Examples

      iex> delete_blog_faq(blog_faq)
      {:ok, %BlogFaq{}}

      iex> delete_blog_faq(blog_faq)
      {:error, %Ecto.Changeset{}}

  """
  def delete_blog_faq(%BlogFaq{} = blog_faq) do
    Repo.delete(blog_faq)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking blog_faq changes.

  ## Examples

      iex> change_blog_faq(blog_faq)
      %Ecto.Changeset{data: %BlogFaq{}}

  """
  def change_blog_faq(%BlogFaq{} = blog_faq, attrs \\ %{}) do
    BlogFaq.changeset(blog_faq, attrs)
  end
end

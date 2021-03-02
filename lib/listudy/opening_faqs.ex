defmodule Listudy.OpeningFaqs do
  @moduledoc """
  The OpeningFaqs context.
  """

  import Ecto.Query, warn: false
  alias Listudy.Repo

  alias Listudy.OpeningFaqs.OpeningFaq

  @doc """
  Returns the list of opening_faq.

  ## Examples

      iex> list_opening_faq()
      [%OpeningFaq{}, ...]

  """
  def list_opening_faq do
    Repo.all(OpeningFaq)
  end

  @doc """
  Gets a single opening_faq.

  Raises `Ecto.NoResultsError` if the Opening faq does not exist.

  ## Examples

      iex> get_opening_faq!(123)
      %OpeningFaq{}

      iex> get_opening_faq!(456)
      ** (Ecto.NoResultsError)

  """
  def get_opening_faq!(id), do: Repo.get!(OpeningFaq, id)

  @doc """
  Creates a opening_faq.

  ## Examples

      iex> create_opening_faq(%{field: value})
      {:ok, %OpeningFaq{}}

      iex> create_opening_faq(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_opening_faq(attrs \\ %{}) do
    %OpeningFaq{}
    |> OpeningFaq.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a opening_faq.

  ## Examples

      iex> update_opening_faq(opening_faq, %{field: new_value})
      {:ok, %OpeningFaq{}}

      iex> update_opening_faq(opening_faq, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_opening_faq(%OpeningFaq{} = opening_faq, attrs) do
    opening_faq
    |> OpeningFaq.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a opening_faq.

  ## Examples

      iex> delete_opening_faq(opening_faq)
      {:ok, %OpeningFaq{}}

      iex> delete_opening_faq(opening_faq)
      {:error, %Ecto.Changeset{}}

  """
  def delete_opening_faq(%OpeningFaq{} = opening_faq) do
    Repo.delete(opening_faq)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking opening_faq changes.

  ## Examples

      iex> change_opening_faq(opening_faq)
      %Ecto.Changeset{data: %OpeningFaq{}}

  """
  def change_opening_faq(%OpeningFaq{} = opening_faq, attrs \\ %{}) do
    OpeningFaq.changeset(opening_faq, attrs)
  end
end

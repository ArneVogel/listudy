defmodule ListudyWeb.OpeningFaqController do
  use ListudyWeb, :controller

  alias Listudy.OpeningFaqs
  alias Listudy.OpeningFaqs.OpeningFaq

  def index(conn, _params) do
    opening_faq = OpeningFaqs.list_opening_faq()
    render(conn, "index.html", opening_faq: opening_faq)
  end

  def new(conn, _params) do
    changeset = OpeningFaqs.change_opening_faq(%OpeningFaq{})
    openings = Listudy.Openings.list_openings()
    render(conn, "new.html", changeset: changeset, openings: openings)
  end

  def create(conn, %{"opening_faq" => opening_faq_params}) do
    case OpeningFaqs.create_opening_faq(opening_faq_params) do
      {:ok, opening_faq} ->
        conn
        |> put_flash(:info, "Opening faq created successfully.")
        |> redirect(to: Routes.opening_faq_path(conn, :show, opening_faq))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    opening_faq = OpeningFaqs.get_opening_faq!(id)
    render(conn, "show.html", opening_faq: opening_faq)
  end

  def edit(conn, %{"id" => id}) do
    opening_faq = OpeningFaqs.get_opening_faq!(id)
    openings = Listudy.Openings.list_openings()
    changeset = OpeningFaqs.change_opening_faq(opening_faq)
    render(conn, "edit.html", opening_faq: opening_faq, changeset: changeset, openings: openings)
  end

  def update(conn, %{"id" => id, "opening_faq" => opening_faq_params}) do
    opening_faq = OpeningFaqs.get_opening_faq!(id)

    case OpeningFaqs.update_opening_faq(opening_faq, opening_faq_params) do
      {:ok, opening_faq} ->
        conn
        |> put_flash(:info, "Opening faq updated successfully.")
        |> redirect(to: Routes.opening_faq_path(conn, :show, opening_faq))

      {:error, %Ecto.Changeset{} = changeset} ->
        openings = Listudy.Openings.list_openings()
        render(conn, "edit.html", opening_faq: opening_faq, changeset: changeset, openings: openings)
    end
  end

  def delete(conn, %{"id" => id}) do
    opening_faq = OpeningFaqs.get_opening_faq!(id)
    {:ok, _opening_faq} = OpeningFaqs.delete_opening_faq(opening_faq)

    conn
    |> put_flash(:info, "Opening faq deleted successfully.")
    |> redirect(to: Routes.opening_faq_path(conn, :index))
  end
end

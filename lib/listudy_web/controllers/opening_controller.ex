defmodule ListudyWeb.OpeningController do
  use ListudyWeb, :controller

  alias Listudy.Tactics
  alias Listudy.Openings
  alias Listudy.Openings.Opening

  def index(conn, _params) do
    openings = Openings.list_openings()
    render(conn, "index.html", openings: openings)
  end

  def new(conn, _params) do
    changeset = Openings.change_opening(%Opening{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"opening" => opening_params}) do
    case Openings.create_opening(opening_params) do
      {:ok, opening} ->
        generate_svg(opening)

        conn
        |> put_flash(:info, "Opening created successfully.")
        |> redirect(to: Routes.opening_path(conn, :show, opening))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    opening = Openings.get_opening!(id)
    render(conn, "show.html", opening: opening)
  end

  # For public usage
  def show(conn, %{"opening" => id}) do
    opening = Openings.get_by_slug!(id)
    studies = Listudy.Studies.get_opening_studies(opening.id)
    tactics_amount = Tactics.opening_count(opening.id)
    tactic = Tactics.get_random_tactic("opening", opening.slug)
    noindex = !index_opening(opening)

    render(conn, "public.html",
      opening: opening,
      tactics_amount: tactics_amount,
      tactic: tactic,
      studies: studies,
      noindex: noindex
    )
  end

  def index_opening(opening) do
    length(String.split(opening.description, " ")) >=
      Application.get_env(:listudy, :seo)[:opening_min_words]
  end

  def edit(conn, %{"id" => id}) do
    opening = Openings.get_opening!(id)
    changeset = Openings.change_opening(opening)
    render(conn, "edit.html", opening: opening, changeset: changeset)
  end

  def update(conn, %{"id" => id, "opening" => opening_params}) do
    opening = Openings.get_opening!(id)

    case Openings.update_opening(opening, opening_params) do
      {:ok, opening} ->
        generate_svg(opening)

        conn
        |> put_flash(:info, "Opening updated successfully.")
        |> redirect(to: Routes.opening_path(conn, :show, opening))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", opening: opening, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    opening = Openings.get_opening!(id)
    {:ok, _opening} = Openings.delete_opening(opening)

    conn
    |> put_flash(:info, "Opening deleted successfully.")
    |> redirect(to: Routes.opening_path(conn, :index))
  end

  defp generate_svg(opening) do
    generate_svg(name(opening.slug), opening.moves)
  end

  defp name(slug) do
    path = "priv/static/images/opening/"
    File.mkdir(path)
    path <> slug <> ".svg"
  end

  defp generate_svg(output, moves) do
    System.cmd("python3", ["scripts/action/svg_generator.py", "--output", output, "--pgn", moves])
  end
end

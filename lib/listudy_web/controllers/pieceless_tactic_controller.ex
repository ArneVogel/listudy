defmodule ListudyWeb.PiecelessTacticController do
  use ListudyWeb, :controller

  alias Listudy.PiecelessTactics
  alias Listudy.PiecelessTactics.PiecelessTactic

  def index(conn, _params) do
    piecelesstactic = PiecelessTactics.list_piecelesstactic()
    render(conn, "index.html", piecelesstactic: piecelesstactic)
  end

  def new(conn, _params) do
    changeset = PiecelessTactics.change_pieceless_tactic(%PiecelessTactic{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pieceless_tactic" => pieceless_tactic_params}) do
    case PiecelessTactics.create_pieceless_tactic(pieceless_tactic_params) do
      {:ok, pieceless_tactic} ->
        conn
        |> put_flash(:info, "Pieceless tactic created successfully.")
        |> redirect(to: Routes.pieceless_tactic_path(conn, :show, pieceless_tactic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    pieceless_tactic = PiecelessTactics.get_pieceless_tactic!(id)
    render(conn, "show.html", pieceless_tactic: pieceless_tactic)
  end

  def public(conn, %{"id" => id}) do
    pieceless_tactic = PiecelessTactics.get_pieceless_tactic!(id)
    render(conn, "public.html", pieceless_tactic: pieceless_tactic)
  end

  def random(conn, params) do
    tactic = get_random_tactic(params)

    url =
      Routes.pieceless_tactic_path(
        conn,
        :public,
        conn.private.plug_session["locale"],
        tactic
      )

    conn
    |> redirect(to: url)
  end

  # exlude the id from the pool of possible randoms
  defp get_random_tactic(%{"id" => id}) do
    Listudy.PiecelessTactics.get_random_tactic(id)
  end
  defp get_random_tactic(_) do
    Listudy.PiecelessTactics.get_random_tactic()
  end

  def edit(conn, %{"id" => id}) do
    pieceless_tactic = PiecelessTactics.get_pieceless_tactic!(id)
    changeset = PiecelessTactics.change_pieceless_tactic(pieceless_tactic)
    render(conn, "edit.html", pieceless_tactic: pieceless_tactic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pieceless_tactic" => pieceless_tactic_params}) do
    pieceless_tactic = PiecelessTactics.get_pieceless_tactic!(id)

    case PiecelessTactics.update_pieceless_tactic(pieceless_tactic, pieceless_tactic_params) do
      {:ok, pieceless_tactic} ->
        conn
        |> put_flash(:info, "Pieceless tactic updated successfully.")
        |> redirect(to: Routes.pieceless_tactic_path(conn, :show, pieceless_tactic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pieceless_tactic: pieceless_tactic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    pieceless_tactic = PiecelessTactics.get_pieceless_tactic!(id)
    {:ok, _pieceless_tactic} = PiecelessTactics.delete_pieceless_tactic(pieceless_tactic)

    conn
    |> put_flash(:info, "Pieceless tactic deleted successfully.")
    |> redirect(to: Routes.pieceless_tactic_path(conn, :index))
  end
end

defmodule ListudyWeb.TacticController do
  use ListudyWeb, :controller

  alias Listudy.Tactics
  alias Listudy.Tactics.Tactic

  def index(conn, _params) do
    tactics = Tactics.list_tactics()
    render(conn, "index.html", tactics: tactics)
  end

  def new(conn, _params) do
    changeset = Tactics.change_tactic(%Tactic{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tactic" => tactic_params}) do
    case Tactics.create_tactic(tactic_params) do
      {:ok, tactic} ->
        conn
        |> put_flash(:info, "Tactic created successfully.")
        |> redirect(to: Routes.tactic_path(conn, :show, tactic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tactic = Tactics.get_tactic!(id)
    render(conn, "show.html", tactic: tactic)
  end

  def edit(conn, %{"id" => id}) do
    tactic = Tactics.get_tactic!(id)
    changeset = Tactics.change_tactic(tactic)
    render(conn, "edit.html", tactic: tactic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tactic" => tactic_params}) do
    tactic = Tactics.get_tactic!(id)

    case Tactics.update_tactic(tactic, tactic_params) do
      {:ok, tactic} ->
        conn
        |> put_flash(:info, "Tactic updated successfully.")
        |> redirect(to: Routes.tactic_path(conn, :show, tactic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tactic: tactic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tactic = Tactics.get_tactic!(id)
    {:ok, _tactic} = Tactics.delete_tactic(tactic)

    conn
    |> put_flash(:info, "Tactic deleted successfully.")
    |> redirect(to: Routes.tactic_path(conn, :index))
  end
end

defmodule ListudyWeb.BlindTacticController do
  use ListudyWeb, :controller

  alias Listudy.BlindTactics
  alias Listudy.BlindTactics.BlindTactic

  def index(conn, _params) do
    blind_tactics = BlindTactics.list_blind_tactics()
    render(conn, "index.html", blind_tactics: blind_tactics)
  end

  def new(conn, _params) do
    changeset = BlindTactics.change_blind_tactic(%BlindTactic{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"blind_tactic" => blind_tactic_params}) do
    case BlindTactics.create_blind_tactic(blind_tactic_params) do
      {:ok, blind_tactic} ->
        conn
        |> put_flash(:info, "Blind tactic created successfully.")
        |> redirect(to: Routes.blind_tactic_path(conn, :show, blind_tactic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    blind_tactic = BlindTactics.get_blind_tactic!(id)
    render(conn, "show.html", blind_tactic: blind_tactic)
  end

  def edit(conn, %{"id" => id}) do
    blind_tactic = BlindTactics.get_blind_tactic!(id)
    changeset = BlindTactics.change_blind_tactic(blind_tactic)
    render(conn, "edit.html", blind_tactic: blind_tactic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "blind_tactic" => blind_tactic_params}) do
    blind_tactic = BlindTactics.get_blind_tactic!(id)

    case BlindTactics.update_blind_tactic(blind_tactic, blind_tactic_params) do
      {:ok, blind_tactic} ->
        conn
        |> put_flash(:info, "Blind tactic updated successfully.")
        |> redirect(to: Routes.blind_tactic_path(conn, :show, blind_tactic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", blind_tactic: blind_tactic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    blind_tactic = BlindTactics.get_blind_tactic!(id)
    {:ok, _blind_tactic} = BlindTactics.delete_blind_tactic(blind_tactic)

    conn
    |> put_flash(:info, "Blind tactic deleted successfully.")
    |> redirect(to: Routes.blind_tactic_path(conn, :index))
  end

  def random(conn, _params) do
    tactic = Listudy.BlindTactics.get_random_tactic()
    url = Routes.blind_tactics_path(conn, ListudyWeb.BlindTacticsLive, conn.private.plug_session["locale"], tactic)
    conn
    |> redirect(to: url)
  end
end

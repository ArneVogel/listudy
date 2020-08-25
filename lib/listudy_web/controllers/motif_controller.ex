defmodule ListudyWeb.MotifController do
  use ListudyWeb, :controller

  alias Listudy.Tactics
  alias Listudy.Motifs
  alias Listudy.Motifs.Motif

  def index(conn, _params) do
    motifs = Motifs.list_motifs()
    render(conn, "index.html", motifs: motifs)
  end

  def new(conn, _params) do
    changeset = Motifs.change_motif(%Motif{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"motif" => motif_params}) do
    case Motifs.create_motif(motif_params) do
      {:ok, motif} ->
        conn
        |> put_flash(:info, "Motif created successfully.")
        |> redirect(to: Routes.motif_path(conn, :show, motif))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    motif = Motifs.get_motif!(id)
    render(conn, "show.html", motif: motif)
  end

  # For public usage
  def show(conn, %{"motif" => id}) do
    motif = Motifs.get_by_slug!(id)
    tactics_amount = Tactics.motif_count(motif.id)
    render(conn, "public.html", motif: motif, tactics_amount: tactics_amount)
  end


  def edit(conn, %{"id" => id}) do
    motif = Motifs.get_motif!(id)
    changeset = Motifs.change_motif(motif)
    render(conn, "edit.html", motif: motif, changeset: changeset)
  end

  def update(conn, %{"id" => id, "motif" => motif_params}) do
    motif = Motifs.get_motif!(id)

    case Motifs.update_motif(motif, motif_params) do
      {:ok, motif} ->
        conn
        |> put_flash(:info, "Motif updated successfully.")
        |> redirect(to: Routes.motif_path(conn, :show, motif))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", motif: motif, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    motif = Motifs.get_motif!(id)
    {:ok, _motif} = Motifs.delete_motif(motif)

    conn
    |> put_flash(:info, "Motif deleted successfully.")
    |> redirect(to: Routes.motif_path(conn, :index))
  end
end

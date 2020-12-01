defmodule ListudyWeb.ExpertRecommendationController do
  use ListudyWeb, :controller

  alias Listudy.ExpertRecommendations
  alias Listudy.Books
  alias Listudy.Players
  alias Listudy.ExpertRecommendations.ExpertRecommendation

  def index(conn, _params) do
    expert_recommendation = ExpertRecommendations.list_expert_recommendation()
    render(conn, "index.html", expert_recommendation: expert_recommendation)
  end

  def new(conn, _params) do
    changeset = ExpertRecommendations.change_expert_recommendation(%ExpertRecommendation{})
    players = Players.list_players()
    books = Books.list_books()
    render(conn, "new.html", changeset: changeset, players: players, books: books)
  end

  def create(conn, %{"expert_recommendation" => expert_recommendation_params}) do
    case ExpertRecommendations.create_expert_recommendation(expert_recommendation_params) do
      {:ok, expert_recommendation} ->
        conn
        |> put_flash(:info, "Expert recommendation created successfully.")
        |> redirect(to: Routes.expert_recommendation_path(conn, :show, expert_recommendation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    expert_recommendation = ExpertRecommendations.get_expert_recommendation!(id)
    render(conn, "show.html", expert_recommendation: expert_recommendation)
  end

  def edit(conn, %{"id" => id}) do
    expert_recommendation = ExpertRecommendations.get_expert_recommendation!(id)
    changeset = ExpertRecommendations.change_expert_recommendation(expert_recommendation)
    render(conn, "edit.html", expert_recommendation: expert_recommendation, changeset: changeset)
  end

  def update(conn, %{"id" => id, "expert_recommendation" => expert_recommendation_params}) do
    expert_recommendation = ExpertRecommendations.get_expert_recommendation!(id)

    case ExpertRecommendations.update_expert_recommendation(
           expert_recommendation,
           expert_recommendation_params
         ) do
      {:ok, expert_recommendation} ->
        conn
        |> put_flash(:info, "Expert recommendation updated successfully.")
        |> redirect(to: Routes.expert_recommendation_path(conn, :show, expert_recommendation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          expert_recommendation: expert_recommendation,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    expert_recommendation = ExpertRecommendations.get_expert_recommendation!(id)

    {:ok, _expert_recommendation} =
      ExpertRecommendations.delete_expert_recommendation(expert_recommendation)

    conn
    |> put_flash(:info, "Expert recommendation deleted successfully.")
    |> redirect(to: Routes.expert_recommendation_path(conn, :index))
  end
end

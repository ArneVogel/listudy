defmodule ListudyWeb.StudyController do
  use ListudyWeb, :controller

  alias Listudy.Users
  alias Listudy.Studies
  alias Listudy.Studies.Study
  alias Listudy.StudyFavorites

  def index(conn, _params) do
    user =
      case get_user(conn) do
        {:ok, user} -> user.id
        {:error, _} -> -1
      end

    studies = Studies.get_study_by_user!(user)
    favorites = Studies.get_studies_by_favorite!(user)
    render(conn, "index.html", studies: studies, favorites: favorites)
  end

  def new(conn, _params) do
    case get_user(conn) do
      {:ok, _} ->
        changeset = Studies.change_study(%Study{})
        render(conn, "new.html", changeset: changeset)

      {:error, error} ->
        conn
        |> put_flash(:info, error)
        |> redirect(to: Routes.pow_registration_path(conn, :new))
    end
  end

  def create(conn, %{"study" => study_params}) do
    with {:ok, user} <- get_user(conn),
         {:ok, pgn} <- check_pgn(study_params) do
      creator = user.id
      # create a slug from the title
      id = Listudy.Slug.random_alnum()
      title_slug = Listudy.Slug.slugify(study_params["title"])
      slug = create_slug(id, title_slug)
      study_params = Map.put(study_params, "slug", slug)

      # Reference the logged in user as creator
      study_params = Map.put(study_params, "user_id", creator)

      # keep the uploaded file
      file = id <> ".pgn"
      save_pgn(pgn, file)

      case Studies.create_study(study_params) do
        {:ok, study} ->
          conn
          |> put_flash(:info, "Study created successfully.")
          |> redirect(
            to: Routes.study_path(conn, :show, conn.private.plug_session["locale"], study)
          )

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      {:error, reason} ->
        changeset = Studies.change_study(%Study{})

        conn
        |> put_flash(:info, reason)
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    study = Studies.get_study_by_slug!(id)
    # if the study has less than the min favorites => noindex it
    noindex =
      StudyFavorites.count_favorites(study.id) <
        Application.get_env(:listudy, :seo)[:study_min_favorites]

    user_id =
      case get_user(conn) do
        {:ok, user} -> user.id
        {:error, _} -> -1
      end

    if study != nil and (!study.private or study.user_id == user_id) do
      study = Map.put(study, :is_owner, study.user_id == user_id)
      # todo maybe reduce the number of extra querys
      study = Map.put(study, :favorites, StudyFavorites.user_favorites_study(user_id, study.id))
      study = Map.put(study, :user, Users.get_user!(study.user_id))
      [unique_id | _] = id |> String.split("-")
      file = unique_id <> ".pgn"
      {_, pgn} = File.read(get_path(file))
      study = Map.put(study, :pgn, pgn)
      render(conn, "show.html", study: study, noindex: noindex)
    else
      redir_study = Studies.get_study_by_slug_start(id_from_slug(id))

      if redir_study != nil and !redir_study.private do
        conn
        |> redirect(
          to: Routes.study_path(conn, :show, conn.private.plug_session["locale"], redir_study)
        )
      else
        conn
        |> put_flash(:error, "This study is private.")
        |> redirect(
          to:
            Routes.search_path(
              conn,
              ListudyWeb.StudySearchLive,
              conn.private.plug_session["locale"]
            )
        )
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    study = Studies.get_study_by_slug!(id)
    {_, user} = get_user(conn)

    if allowed(study, user) do
      changeset = Studies.change_study(study)
      render(conn, "edit.html", study: study, changeset: changeset)
    else
      conn
      |> put_flash(:error, "This study is private.")
      |> redirect(
        to:
          Routes.search_path(
            conn,
            ListudyWeb.StudySearchLive,
            conn.private.plug_session["locale"]
          )
      )
    end
  end

  def update(conn, %{"id" => id, "study" => study_params}) do
    study = Studies.get_study_by_slug!(id)
    {_, user} = get_user(conn)
    [unique_id | _] = id |> String.split("-")
    file = unique_id <> ".pgn"
    title_slug = Listudy.Slug.slugify(study_params["title"])
    slug = create_slug(unique_id, title_slug)
    study_params = Map.put(study_params, "slug", slug)

    if allowed(study, user) do
      case Studies.update_study(study, study_params) do
        {:ok, study} ->
          case check_pgn(study_params) do
            {:ok, pgn} ->
              save_pgn(pgn, file)

              conn
              |> put_flash(:info, gettext("Study info updated, PGN changed."))
              |> redirect(
                to: Routes.study_path(conn, :show, conn.private.plug_session["locale"], study)
              )

            {:error, _} ->
              conn
              |> put_flash(:info, gettext("Study info updated, no PGN change."))
              |> redirect(
                to: Routes.study_path(conn, :show, conn.private.plug_session["locale"], study)
              )
          end

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", study: study, changeset: changeset)
      end
    else
      conn
      |> put_flash(:info, "You're not allowed to do that.")
      |> redirect(to: Routes.study_path(conn, :index, conn.private.plug_session["locale"]))
    end
  end

  def delete(conn, %{"id" => id}) do
    study = Studies.get_study_by_slug!(id)

    {_, user} = get_user(conn)

    if !allowed(study, user) do
      conn
      |> put_flash(:info, "You're not allowed to do that.")
      |> redirect(to: Routes.study_path(conn, :index, conn.private.plug_session["locale"]))
    else
      {:ok, _study} = Studies.delete_study(study)

      conn
      |> put_flash(:info, "Study deleted successfully.")
      |> redirect(to: Routes.study_path(conn, :index, conn.private.plug_session["locale"]))
    end
  end

  defp create_slug(id, title_slug) do
    id <> "-" <> title_slug
  end

  defp id_from_slug(slug) do
    hd(String.split(slug, "-"))
  end

  defp allowed(study, user) do
    study.user_id == user.id || user.role == "admin"
  end

  defp get_user(conn) do
    case Pow.Plug.current_user(conn) != nil do
      true -> {:ok, Pow.Plug.current_user(conn)}
      _ -> {:error, gettext("Please log in")}
    end
  end

  # Checks if the study_params have a valid pgn
  # Either a pgn was uploaded ->
  #   check the size 
  # Or a lichess study was provided ->
  #   download the pgn from lichess and create a file
  # Returns the file path on success
  defp check_pgn(%{"pgn" => pgn}) do
    file = pgn.path

    case File.stat(file) do
      {:ok, %{size: size}} ->
        if size < 50000 do
          {:ok, file}
        else
          {:error, gettext("PGN is too big, only 50kb allowed")}
        end

      {:error, _} ->
        "Error"
    end
  end

  defp check_pgn(%{"lichess_study" => lichess_study}) when lichess_study != "" do
    case String.starts_with?(lichess_study, "https://lichess.org/study/") do
      true ->
        url = lichess_study <> ".pgn"

        case HTTPoison.get(url) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            dir = "/tmp/listudy/"
            File.mkdir(dir)
            id = dir <> Listudy.Slug.random_alnum() <> ".pgn"
            {:ok, file} = File.open(id, [:write])
            IO.binwrite(file, body)
            {:ok, id}

          _ ->
            {:error, gettext("Could not download the study from lichess, please check the link")}
        end

      _ ->
        {:error, gettext("The provided link is not a Lichess study")}
    end
  end

  defp check_pgn(_study_params) do
    {:error, gettext("No PGN provided")}
  end

  defp get_path(file) do
    "priv/static/study_pgn/" <> file
  end

  def favorite_study(conn, %{"study_id" => study_id}) do
    user_id = Pow.Plug.current_user(conn).id

    {_, message} =
      case StudyFavorites.favorite_study(%{study_id: study_id, user_id: user_id}) do
        {:ok, _} ->
          {:ok, gettext("Study favorited")}

        {:error, %Ecto.Changeset{} = _changeset} ->
          {:error, gettext("Could not favorite this study")}
      end

    conn
    |> put_flash(:info, message)
    |> redirect(to: NavigationHistory.last_path(conn))
  end

  def unfavorite_study(conn, %{"study_id" => study_id}) do
    user_id = Pow.Plug.current_user(conn).id

    {_, message} =
      case StudyFavorites.unfavorite_study(user_id, study_id) do
        {:ok, _} ->
          {:ok, gettext("Study unfavorited")}

        {:error, %Ecto.Changeset{} = _changeset} ->
          {:error, gettext("Could not unfavorite this study")}
      end

    conn
    |> put_flash(:info, message)
    |> redirect(to: NavigationHistory.last_path(conn))
  end

  # pgn is the path to the pgn file
  # target_file is the name the file should be saved as
  defp save_pgn(pgn, file_name) do
    File.cp(pgn, get_path(file_name))
    File.rm(pgn)
  end
end

defmodule ListudyWeb.StatsController do
  use ListudyWeb, :controller

  alias Listudy.Users
  alias Listudy.Studies

  def index(conn, _params) do
    studies = Studies.study_aggregate()
    users = Users.user_aggregate()
    render(conn, "index.html", studies: studies, users: users)
  end
end

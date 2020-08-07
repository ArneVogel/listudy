defmodule ListudyWeb.Plugs.LastVisited do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{assigns: %{current_user: %{id: id}}} = conn, _default) do
    Listudy.Users.visited_now(id)
    conn
  end

  def call(conn, _default) do
    conn
  end
end

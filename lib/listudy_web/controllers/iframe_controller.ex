defmodule ListudyWeb.IframeController do
  use ListudyWeb, :controller

  def custom_tactic(conn, _params) do
    render(conn, "custom_tactic.html")
  end
end

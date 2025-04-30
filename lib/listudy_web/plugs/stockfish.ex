defmodule ListudyWeb.Plugs.Stockfish do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    put_resp_header(conn, "cross-origin-embedder-policy", "unsafe-none")
  end
end

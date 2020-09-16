defmodule ListudyWeb.Plugs.Stockfish do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    put_resp_header conn, "Cross-Origin-Embedder-Policy", "require-corp"
    put_resp_header conn, "Cross-Origin-Opener-Policy", "same-origin"
  end
end

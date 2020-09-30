defmodule ListudyWeb.Plugs.AllowIframe do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _options) do
    conn
    |> delete_resp_header("x-frame-options")
  end
end

defmodule ListudyWeb.Plugs.CSP do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    nonce = nonce()
    conn = put_session(conn, :csp_nonce, nonce)
    put_resp_header(conn, "content-security-policy", csp(conn))
  end

  def put_nonce(%{private: %{plug_session: %{"csp_nonce" => nonce}}}) do
    " nonce=\"#{nonce}\" "
  end

  def put_nonce(%{private: %{conn_session: %{"csp_nonce" => nonce}}}) do
    " nonce=\"#{nonce}\" "
  end

  def put_nonce(_) do
    ""
  end

  defp csp(conn) do
    "default-src 'self' data: *.googlesyndication.com; \
    base-uri 'self'; \
    object-src 'none'; \
    connect-src 'self' wss://listudy.org ws://listudy.org #{ws_url(conn)} #{ws_url(conn, "wss")} https://pagead2.googlesyndication.com; \
    script-src 'self' 'unsafe-inline' 'unsafe-eval' 'nonce-#{
      conn.private.plug_session["csp_nonce"]
    }' data: pagead2.googlesyndication.com; \
    img-src 'self' data: *.googlesyndication.com; \
    font-src 'self' data:; \
    frame-ancestors 'self'; \
    style-src 'self' 'unsafe-inline'"
  end

  defp ws_url(conn, protocol \\ "ws") do
    endpoint = Phoenix.Controller.endpoint_module(conn)
    %{endpoint.struct_url | scheme: protocol} |> URI.to_string()
  end

  defp nonce() do
    min = String.to_integer("100000000000", 36)
    max = String.to_integer("ZZZZZZZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end
end

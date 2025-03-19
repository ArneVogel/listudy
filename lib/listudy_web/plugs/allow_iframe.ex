defmodule ListudyWeb.Plugs.AllowIframe do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _options) do
    # Retrieve the nonce that the main CSP plug stored in the session
    nonce = conn.private.plug_session["csp_nonce"]

    # Construct a new Content-Security-Policy for iframe routes
    # Here, we allow embedding from any domain by setting frame-ancestors to '*'.
    csp_value = """
    default-src 'self' data: *.googlesyndication.com;
    base-uri 'self';
    object-src 'none';
    connect-src 'self' wss://listudy.org ws://listudy.org #{ws_url(conn)} #{ws_url(conn, "wss")} https://pagead2.googlesyndication.com;
    script-src 'self' 'unsafe-inline' 'unsafe-eval' 'nonce-#{nonce}' data: pagead2.googlesyndication.com;
    img-src 'self' data: *.googlesyndication.com;
    font-src 'self' data:;
    frame-ancestors *;
    style-src 'self' 'unsafe-inline'
    """

    conn
    |> delete_resp_header("x-frame-options")
    |> put_resp_header("content-security-policy", csp_value)
  end

  defp ws_url(conn, protocol \\ "ws") do
    endpoint = Phoenix.Controller.endpoint_module(conn)
    %{endpoint.struct_url | scheme: protocol} |> URI.to_string()
  end
end

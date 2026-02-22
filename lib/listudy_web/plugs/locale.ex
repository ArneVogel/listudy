defmodule ListudyWeb.Plugs.Locale do
  import Plug.Conn

  @locales Application.compile_env(:listudy, [:languages, :translations])
  @default Application.compile_env(:listudy, [:languages, :default])

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    Gettext.put_locale(loc)
    conn = put_session(conn, :locale, loc)
    assign(conn, :locale, loc)
  end

  def call(conn, _default) do
    {_, loc} = get_locale(conn)
    Gettext.put_locale(loc)

    conn = put_session(conn, :locale, loc)
    assign(conn, :locale, loc)
  end

  defp default_locale(), do: @default

  defp get_locale(conn) do
    if conn.private.plug_session["locale"] do
      {:ok, conn.private.plug_session["locale"]}
    else
      {:noset, default_locale()}
    end
  end
end

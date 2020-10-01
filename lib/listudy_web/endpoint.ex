defmodule ListudyWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :listudy

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "listudy_session",
    signing_salt: "/aWs928X",
    extra: "SameSite=Lax;Secure"
  ]

  socket "/socket", ListudyWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :listudy,
    gzip: false,
    cache_control_for_etags: "public, max-age=31536000",
    only:
      ~w(css fonts images js sounds favicon.ico robots.txt 
        android-chrome-192x192.png android-chrome-512x512.png apple-touch-icon.png browserconfig.xml favicon-16x16.png favicon-32x32.png favicon.ico mstile-144x144.png mstile-150x150.png mstile-310x150.png mstile-310x310.png mstile-70x70.png safari-pinned-tab.svg site.webmanifest)

  plug Plug.Static,
    at: "/",
    from: :listudy,
    gzip: false,
    cache_control_for_etags: "public, max-age=31536000",
    only: ~w(stockfish),
    headers: %{"cross-origin-embedder-policy" => "require-corp"},
    content_types: %{"stockfish.wasm" => "application/wasm"}

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :listudy
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug Pow.Plug.Session, otp_app: :listudy

  plug PowPersistentSession.Plug.Cookie,
    persistent_session_ttl: (:timer.hours(24) * 365)

  plug ListudyWeb.Router
end

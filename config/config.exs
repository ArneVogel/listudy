# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :listudy,
  ecto_repos: [Listudy.Repo]

# Configures the endpoint
config :listudy, ListudyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "q1+sTm1AFrNRM4y+xMkcjSe796tzWQ7N+vYziJIIX49liQrByhc+2xSKC9O8j113",
  render_errors: [view: ListudyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Listudy.PubSub,
  live_view: [signing_salt: "K29dK2Yj"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :listudy, :pow,
  user: Listudy.Users.User,
  repo: Listudy.Repo,
  extensions: [PowPersistentSession],
  web_module: ListudyWeb,
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  cache_store_backend: Pow.Store.Backend.MnesiaCache

config :mnesia, dir: 'priv/mnesia'

config :gettext, :default_locale, "en"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

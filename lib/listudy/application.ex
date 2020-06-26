defmodule Listudy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Listudy.Repo,
      # Start the Telemetry supervisor
      ListudyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Listudy.PubSub},
      # Start the Endpoint (http/https)
      ListudyWeb.Endpoint,
      # Start a worker by calling: Listudy.Worker.start_link(arg)
      # {Listudy.Worker, arg}
      # Persistent Cache for Pow
      Pow.Store.Backend.MnesiaCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Listudy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ListudyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule LrucacheApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LrucacheApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LrucacheApi.PubSub},
      # Start the Endpoint (http/https)
      LrucacheApiWeb.Endpoint,
      # Start the Cache GenServer with a Name, cache name and cache capacity
      {Cache.Server, name: :mycache, cache_name: "mycache", cache_capacity: 5} 
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LrucacheApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LrucacheApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

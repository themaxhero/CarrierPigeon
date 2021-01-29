defmodule CarrierPigeon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CarrierPigeon.Repo,
      # Start the Telemetry supervisor
      CarrierPigeonWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CarrierPigeon.PubSub},
      # Start the Endpoint (http/https)
      CarrierPigeonWeb.Endpoint
      # Start a worker by calling: CarrierPigeon.Worker.start_link(arg)
      # {CarrierPigeon.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CarrierPigeon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CarrierPigeonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Checkout.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CheckoutWeb.Telemetry,
      Checkout.Repo,
      {DNSCluster, query: Application.get_env(:checkout, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Checkout.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Checkout.Finch},
      # Start a worker by calling: Checkout.Worker.start_link(arg)
      # {Checkout.Worker, arg},
      # Start to serve requests, typically the last entry
      CheckoutWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Checkout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CheckoutWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

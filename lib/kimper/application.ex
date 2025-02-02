defmodule Kimper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Dotenv.load()

    children = [
      Kimper.Storage,
      Kimper.UpbitPriceFetcher,
      {Kimper.BybitPriceFetcher, %{}},
      Kimper.BybitFundingRateFetcher,
      Kimper.ExchangeRateFetcher,
      Kimper.KospiFetcher,
      Kimper.KosdaqFetcher,
      Kimper.NasdaqFetcher,
      KimperWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:kimper, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Kimper.PubSub},
      # Start a worker by calling: Kimper.Worker.start_link(arg)
      # {Kimper.Worker, arg},
      # Start to serve requests, typically the last entry
      KimperWeb.Endpoint,
      Kimper.Scheduler,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: Kimper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KimperWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

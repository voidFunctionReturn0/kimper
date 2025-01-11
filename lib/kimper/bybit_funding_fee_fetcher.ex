# TODO: 작성 중
defmodule Kimper.BybitFundingFeeFetcher do
  use GenServer

  # @interval 1_000
  # @coins %{
  #   btc_usd: "BTCUSD",
  #   eth_usd: "ETHUSD",
  # }

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    # schedule_fetch_funding_rate()
    {:ok, state}
  end

  # defp schedule_fetch_funding_rate do
  #   Process.send_after(self(), :fetch_funding_rate, @interval)
  # end

  # def handle_info(:fetch_funding_rate, state) do
  #   Enum.each(@coins, &fetch_funding_rate/1)
  #   schedule_fetch_funding_rate()
  #   {:noreply, state}
  # end
end

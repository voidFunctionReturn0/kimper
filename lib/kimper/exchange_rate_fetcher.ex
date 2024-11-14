defmodule Kimper.ExchangeRateFetcher do
  use GenServer

  @initial_state %{usd_krw_rate: nil}
  @exchange_rate_api_url "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json"  # 참고: https://github.com/fawazahmed0/exchange-api

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :fetch_exchange_rate, 0)
    {:ok, state}
  end

  def fetch_exchange_rate, do: Process.send_after(self(), :fetch_exchange_rate, 0)

  def handle_info(:fetch_exchange_rate, state) do
    new_exchange_rate = fetch_usd_krw_rate()
    Kimper.Storage.set_exchange_rate(new_exchange_rate)
    {:noreply, %{state | usd_krw_rate: new_exchange_rate}}
  end

  defp fetch_usd_krw_rate() do
    response = HTTPoison.get!(@exchange_rate_api_url).body |> Jason.decode!()
    response["usd"]["krw"]
  end
end

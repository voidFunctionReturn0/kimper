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
    {new_exchange_rate, updated_at } = fetch_usd_krw_rate()
    Kimper.Storage.set_exchange_rate(new_exchange_rate)
    Kimper.Storage.set_exchange_rate_updated_at(updated_at) # TODO: 환율 업데이트 문제 해결 후 삭제 요망
    {:noreply, %{state | usd_krw_rate: new_exchange_rate}}
  end

  defp fetch_usd_krw_rate() do
    response = HTTPoison.get!(@exchange_rate_api_url).body |> Jason.decode!()
    {response["usd"]["krw"], response["date"]} # TODO: 환율 업데이트 문제 해결 후 삭제 요망
  end
end

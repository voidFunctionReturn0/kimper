defmodule Kimper.ExchangeRateFetcher do
  use GenServer

  @initial_state %{usd_krw_rate: nil, jpy_krw_rate: nil}
  @usd_krw_exchange_rate_url "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json"  # 참고: https://github.com/fawazahmed0/exchange-api
  @jpy_krw_exchange_rate_url "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/jpy.json"

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :fetch_exchange_rate, 0)
    {:ok, state}
  end

  def fetch_exchange_rate, do: Process.send_after(self(), :fetch_exchange_rate, 0)

  def handle_info(:fetch_exchange_rate, state) do
    {new_usd_krw_exchange_rate, usd_krw_updated_at} = fetch_usd_krw_rate()
    {new_jpy_krw_exchange_rate, _updated_at} = fetch_jpy_krw_rate()
    Kimper.Storage.set_usd_krw_exchange_rate(new_usd_krw_exchange_rate)
    Kimper.Storage.set_usd_krw_exchange_rate_updated_at(usd_krw_updated_at) # TODO: 환율 업데이트 문제 해결 후 삭제 요망
    Kimper.Storage.set_jpy_krw_exchange_rate(new_jpy_krw_exchange_rate)
    {
      :noreply,
      state
      |> Map.put(:usd_krw_rate, new_usd_krw_exchange_rate)
      |> Map.put(:jpy_krw_rate, new_jpy_krw_exchange_rate)
    }
  end

  defp fetch_usd_krw_rate() do
    response = HTTPoison.get!(@usd_krw_exchange_rate_url).body |> Jason.decode!()
    {response["usd"]["krw"], response["date"]} # TODO: 환율 업데이트 문제 해결 후 삭제 요망
  end

  defp fetch_jpy_krw_rate() do
    response = HTTPoison.get!(@jpy_krw_exchange_rate_url).body |> Jason.decode!()
    {response["jpy"]["krw"], response["date"]}
  end
end

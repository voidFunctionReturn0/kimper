defmodule Kimper.BybitFundingRateFetcher do
  use GenServer
  require Logger
  alias Kimper.Storage

  @interval 60_000
  @coins ["BTCUSD", "SOLUSD", "XRPUSD", "EOSUSD", "ETHUSD"]
  @url "https://api.bytick.com/v5/market/funding/history?category=linear&limit=1"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_fetch_funding_rate()
    {:ok, state}
  end

  def schedule_fetch_funding_rate() do
    Process.send_after(self(), :fetch_funding_rate, @interval)
  end

  def handle_info(:fetch_funding_rate, state) do
    funding_rates = Enum.map(@coins, &fetch_funding_rate/1)
    funding_rates = Enum.zip(@coins, funding_rates)

    Enum.each(funding_rates, fn {coin, funding_rate} ->
      if funding_rate != nil do
        case Float.parse(funding_rate) do
          {rate, _} ->
            case coin do
              "BTCUSD"  -> Storage.set_bybit_usd_funding_rate(rate, :btc)
              "SOLUSD"  -> Storage.set_bybit_usd_funding_rate(rate, :sol)
              "XRPUSD"  -> Storage.set_bybit_usd_funding_rate(rate, :xrp)
              "EOSUSD"  -> Storage.set_bybit_usd_funding_rate(rate, :eos)
              "ETHUSD"  -> Storage.set_bybit_usd_funding_rate(rate, :eth)
              _         -> Logger.error("Unexpected coin")
            end

          _  ->
            Logger.error("Failed to parse funding rate")
        end
      end

      {:noreply, funding_rates}
    end)

    schedule_fetch_funding_rate()

    {:noreply, state}
  end

  defp fetch_funding_rate(ticker) do
    url = "#{@url}&symbol=#{ticker}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"result" => %{"list" => [%{"fundingRate" => funding_fee}]}}} ->
            funding_fee

          _ ->
            Logger.error("Invalid response format")
            nil
        end

      {:ok, %HTTPoison.Response{status_code: code}} ->
        Logger.error("API request failed with status code #{code}")
        nil

      {:error, reason} ->
        Logger.error("Failed to fetch data: #{reason}")
        nil
    end
  end
end

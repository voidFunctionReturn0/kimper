# TODO: 작성 중
defmodule Kimper.BybitFundingRateFetcher do
  use GenServer
  require Logger

  @interval 1_000 # 60초
  @coins ["BTCUSD", "ETHUSD"]
  @url "https://api.bytick.com/v5/market/funding/history?category=linear&limit=1"

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
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
    @coins
    |> Enum.map(&fetch_funding_rate/1)
    |> Enum.each(&IO.inspect/1)

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

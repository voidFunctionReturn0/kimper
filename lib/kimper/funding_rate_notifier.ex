defmodule Kimper.FundingRateNotifier do
  alias Kimper.FundingRateNotifier
  @coin_usd_list [:btc_usd, :eth_usd]
  @bybit_funding_rate_url %{
    btc_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=BTCUSD&limit=1",
    eth_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=ETHUSD&limit=1",
  }
  @telegram_chat_id %{
    btc_usd: "-1002363514381",
    eth_usd: "-1002391778061",
  }

  def notify_funding_rate_iter do
    Enum.each(@coin_usd_list, &FundingRateNotifier.notify_funding_rate/1)
  end

  def notify_funding_rate(coin_usd) do
    case fetch_funding_rate(coin_usd) do
      {:ok, funding_rate} ->
        bot_token = System.get_env("TELEGRAM_BOT_TOKEN")
        telegram_url = "https://api.telegram.org/bot#{bot_token}/sendMessage"
        headers = [{"Content-Type", "application/json"}]
        message = "## 테스트 Bybit #{english(coin_usd)} 펀딩비는 #{String.to_float(funding_rate) * 100}% 입니다."
        body = Jason.encode!(%{
          chat_id: Map.get(@telegram_chat_id, coin_usd),
          text: message
        })

        case HTTPoison.post(telegram_url, body, headers) do
          {:ok, _response} ->
            nil
          {:error, reason} ->
            IO.puts("## Failed to send telegram message: #{reason}")
        end

      {:error, reason} ->
        IO.puts("## Failed to fetch funding rate in notify_funding_rate function: #{reason}")
    end
  end

  defp fetch_funding_rate(coin_usd) do
    url = Map.get(@bybit_funding_rate_url, coin_usd)
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> extract_funding_rate()

      {:error, message} ->
        IO.puts("## Failed to fetch funding rate: #{message}")
        {:error, message.reason}
    end
  end

  defp extract_funding_rate(%{"result" => %{"list" => [%{"fundingRate" => funding_rate}]}}) do
    {:ok, funding_rate}
  end
  defp extract_funding_rate(_), do: {:error, "## No funding rate found"}

  defp english(:btc_usd), do: "BTCUSD"
  defp english(:eth_usd), do: "ETHUSD"
end

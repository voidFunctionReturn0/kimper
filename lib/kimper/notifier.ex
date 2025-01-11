defmodule Kimper.Notifier do
  alias Kimper.Notifier
  alias Kimper.Storage
  @coin_usd_list [:btc_usd, :eth_usd]
  @bybit_funding_rate_url %{
    btc_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=BTCUSD&limit=1",
    eth_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=ETHUSD&limit=1",
  }
  @telegram_chat_id %{
    btc_usd: "-1002363514381",
    eth_usd: "-1002391778061",
  }

  def notify_iter do
    Enum.each(@coin_usd_list, &Notifier.notify/1)
  end

  def notify(coin_usd) do
    case fetch_funding_rate(coin_usd) do
      {:ok, funding_rate} ->
        bot_token = System.get_env("TELEGRAM_BOT_TOKEN")
        telegram_url = "https://api.telegram.org/bot#{bot_token}/sendMessage"
        headers = [{"Content-Type", "application/json"}]
        english_usd = english_usd(coin_usd)
        message = """
        <Bybit>
        - #{english_usd} 펀딩비: #{String.to_float(funding_rate) * 100}%
        - #{english_usdt(english_usd)} 김프: #{kimp(coin_usd) |> Float.floor(2)}%
        """
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

  defp english_usd(:btc_usd), do: "BTCUSD"
  defp english_usd(:eth_usd), do: "ETHUSD"

  defp english_usdt(english_usd), do: "#{english_usd}T"

  defp kimp(:btc_usd), do: Storage.state.btc.kimp
  defp kimp(:eth_usd), do: Storage.state.eth.kimp # TODO: Storage에 ETH KIMP 계산 추가
end

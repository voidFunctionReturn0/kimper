# TODO: BybitFundingRate과 통합 필요(중복 코드 제거하고 Storage에서 펀딩비 가져오도록 수정, 펀딩피 지급 시간에 펀딩비 조회하도록 하는 기능 추가)

defmodule Kimper.Notifier do
  alias Kimper.Notifier
  alias Kimper.Storage
  @coin_usd_list [:btc_usd, :eth_usd]
  @bybit_funding_rate_url %{
    btc_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=BTCUSD&limit=1",
    sol_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=SOLUSD&limit=1",
    xrp_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=XRPUSD&limit=1",
    eos_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=EOSUSD&limit=1",
    eth_usd: "https://api.bytick.com/v5/market/funding/history?category=linear&symbol=ETHUSD&limit=1",
  }
  @telegram_chat_id %{
    btc_usd: "-1002363514381",
    sol_usd: "-1002356719531",
    xrp_usd: "-1002346966522",
    eos_usd: "-1002430099761",
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
  defp english_usd(:sol_usd), do: "SOLUSD"
  defp english_usd(:xrp_usd), do: "XRPUSD"
  defp english_usd(:eos_usd), do: "EOSUSD"
  defp english_usd(:eth_usd), do: "ETHUSD"

  defp english_usdt(english_usd), do: "#{english_usd}T"

  defp kimp(:btc_usd), do: Storage.state.btc.kimp
  defp kimp(:sol_usd), do: Storage.state.sol.kimp
  defp kimp(:xrp_usd), do: Storage.state.xrp.kimp
  defp kimp(:eos_usd), do: Storage.state.eos.kimp
  defp kimp(:eth_usd), do: Storage.state.eth.kimp
end
